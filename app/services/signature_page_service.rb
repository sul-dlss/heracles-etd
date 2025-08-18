# frozen_string_literal: true

# Service for generating the signature pages for an ETD
class SignaturePageService # rubocop:disable Metrics/ClassLength
  class Error < StandardError; end

  DEGREE_MAP = {
    'Ph.D.' => 'Doctor of Philosophy',
    'JSD' => 'Doctor of the Science of Law',
    'DMA' => 'Doctor of Musical Arts',
    'Engineering' => 'Engineering'
  }.freeze

  def self.call(submission:, dissertation_path: nil)
    new(submission:, dissertation_path:).call
  end

  def initialize(submission:, dissertation_path:)
    @submission = submission
    @dissertation_path = dissertation_path
  end

  attr_reader :submission, :dissertation_path

  delegate :dissertation_file, :id, :druid, :readers, :purl, :supplemental_files, :thesis?, :provost,
           :creative_commons_license, :submitted_at, :degreeconfyr,
           :degree, to: :submission

  # @return [String] the path to the augmented PDF
  # @raise Error if fails
  def call # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    Honeybadger.context(submission:)
    raise Error, 'Dissertation PDF not found' unless File.exist?(dissertation_path)

    generate_copyright_and_signature_docs!

    # Merge generated PDF into base PDF on pages 2 and 3
    HexaPDF::Document.open(generated_doc_path).pages.each.with_index(1) do |generated_page, i|
      # NOTE: The first argument to `#insert` here is the page number which is
      #       zero-indexed, so 1 is page 2, 2 is page 3, and so on.
      base_document.pages.insert(i, base_document.import(generated_page))
    end

    begin
      base_document.write(augmented_dissertation_path, optimize: true)
    rescue HexaPDF::Error => e
      Honeybadger.notify("Error writing augmented PDF for #{id} with validation. Retrying once without validation",
                         error_class: e.class,
                         error_message: e.message,
                         backtrace: e.backtrace)
      base_document.write(augmented_dissertation_path, optimize: true, validate: false)
    end

    augmented_dissertation_path
  rescue StandardError => e
    Rails.logger.error("Error generating copyright & signature pages for submission #{id}: #{e}")
    Honeybadger.notify(e)
    raise Error, "Failed to generate signature pages for submission #{id}: #{e.message}"
  ensure
    FileUtils.rm_f(generated_doc_path)
  end

  private

  def augmented_dissertation_path
    @augmented_dissertation_path ||= dissertation_path.sub('.pdf', '-augmented.pdf')
  end

  # This is the PDF associated with the submission, so it can either be the student's
  # submitted PDF or the "preview" PDF if the student has not yet submitted a
  # PDF
  def base_document
    @base_document ||= HexaPDF::Document.open(dissertation_path)
  end

  # This document holds the copyright and signature pages we generate in this
  # class, which are ultimately inserted into the base document
  def document
    @document ||= Prawn::Document.new(margins)
  end

  # We need a deterministic path to the generated document because we generate
  # and write the copyright and signature pages using Prawn, and HexaPDF
  # cannot natively manipulate in-memory Prawn documents, so HexaPDF opens
  # this document anew after Prawn writes it out.
  #
  # And we care about the name of this document so that if something goes
  # wrong we have an easier way to associate a temporary PDF file with a
  # particular submission.
  def generated_doc_path
    @generated_doc_path ||= Dir::Tmpname.create(["submission-#{id}-", '.pdf']) {} # rubocop:disable Lint/EmptyBlock
  end

  def margins
    {
      left_margin: 108,
      right_margin: 72,
      top_margin: 82,
      bottom_margin: 82
    }
  end

  def generate_copyright_and_signature_docs!
    document.font('Times-Roman', size: 12)

    generate_copyright_page!

    # Now create a new page to hold the signature page
    document.start_new_page(margins)

    generate_signature_page!

    # Write the generated file
    document.render_file(generated_doc_path)
  end

  # A big, ugly method that helps us decommission a Java project that we
  # struggle to maintain.
  #
  # At least it should be easier to tweak going forward, despite its ugliness.
  def generate_copyright_page! # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # We expect to see the copyright statement lower than the top margin
    document.move_cursor_to(535)

    # Generate the copyright page first
    document.pad_bottom(25) do
      document.text("\u00A9 #{copyright_year} by #{submission.first_last_name}. All Rights Reserved.", align: :center,
                                                                                                       leading: 7)
      document.text('Re-distributed by Stanford University under license with the author.', align: :center,
                                                                                            leading: 7)
    end

    # Render license information
    if creative_commons_license&.cc_license?
      document.pad(25) do # rubocop:disable Metrics/BlockLength
        document.indent(25) do
          document.image(creative_commons_license.image_path)
          # Linkify the image by placing the annotation *just so*
          document.link_annotation(
            [
              108 + 25, # x: left margin + current indent
              113 + document.cursor - 31, # y: cursor + padding - image_height
              108 + 25 + 88, # width: x + image_width
              113 + document.cursor # height: cursor + padding
            ],
            Border: [0, 0, 0],
            A: {
              Type: :Action,
              S: :URI,
              URI: ::PDF::Core::LiteralString.new(creative_commons_license.url)
            }
          )
          document.move_up(38)
          document.indent(100) do
            document.text('This work is licensed under a Creative Commons Attribution-', leading: 2)
            document.text("#{creative_commons_license.signature_text}.", leading: 2)
            document.text(
              "<color rgb='0000FF'><u><link href='#{creative_commons_license.url}'>#{creative_commons_license.url}</link></u></color>", # rubocop:disable Metrics/LineLength
              inline_format: true,
              leading: 2
            )
          end
        end
      end
    else
      # Pad out the space that would have been taken by the license
      document.pad(45) { document.text('') }
    end

    # Generate PURL link
    document.pad(25) do
      document.text(
        "This dissertation is online at: <color rgb='0000FF'><u><link href='#{purl}'>#{purl}</link></u></color>",
        inline_format: true
      )
    end

    # Render supplemental file information
    if supplemental_files.any?
      document.font('Times-Roman', size: 11) do
        document.text('Includes supplemental files:', leading: 2)
        # This jazz with indenting the whole files block and then using a
        # negative paragraph indent? That's the best way I've found to
        # indent only text on subsequent lines, which is the behavior we
        # want: the line beginning with the index should be flush with the
        # 'Includes supplemental files' heading and any text that wraps
        # should indent inside the index.
        document.indent(10) do
          supplemental_files.each.with_index(1) do |file, i|
            file_listing_parts = [
              "#{i}.",
              file.label&.truncate(120),
              "<i>(#{file.file_name})</i>"
            ]
            document.text(
              file_listing_parts.compact_blank.join(' '),
              inline_format: true,
              leading: 2,
              indent_paragraphs: -10
            )
          end
        end
      end
    end

    # Draw the page number as a Roman numeral in the footer
    document.draw_text('ii', at: [190, -40], size: 8)
  end

  # A big, ugly method that helps us decommission a Java project that we
  # struggle to maintain.
  #
  # At least it should be easier to tweak going forward, despite its ugliness.
  def generate_signature_page! # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # Render reader signatures
    if readers.any?
      if thesis?
        # Include engineering-specific verbiage
        document.text('Approved for the department.')
        document.pad(15) do
          document.font('Times-Roman', style: :bold) do
            readers.each do |reader|
              name = reader.first_last_name
              name << ', Adviser'
              document.text(
                name,
                align: :right,
                leading: 7
              )
            end
          end
        end
        document.pad(35) do
          document.text('Approved for the Stanford University Committee on Graduate Studies.')
          document.pad(12) do
            document.font('Times-Roman', style: :bold) do
              document.text(
                "#{provost}, Vice Provost for Graduate Education",
                align: :right,
                leading: 7
              )
            end
          end
        end
        document.font('Times-Roman', size: 11, style: :italic) do
          document.text(
            'This signature page was generated electronically upon submission of this thesis in electronic format.',
            valign: :bottom
          )
        end
      else
        # Include generic dissertation verbiage
        readers.each do |reader|
          document.pad_bottom(25) do
            document.text(
              'I certify that I have read this dissertation and that, in my opinion, it is fully adequate in scope ' \
              "and quality as a dissertation for the degree of #{DEGREE_MAP.fetch(degree)}."
            )
            document.pad_top(12) do
              document.font('Times-Roman', style: :bold) do
                name = reader.first_last_name
                name << ", #{reader.signature_page_role}" if reader.signature_page_role.present?
                document.text(
                  name,
                  align: :right,
                  leading: 7
                )
              end
            end
          end
        end
        document.pad(35) do
          document.text('Approved for the Stanford University Committee on Graduate Studies.')
          document.pad(12) do
            document.font('Times-Roman', style: :bold) do
              document.text(
                "#{provost}, Vice Provost for Graduate Education",
                align: :right,
                leading: 7
              )
            end
          end
        end
        document.font('Times-Roman', size: 11, style: :italic) do
          document.text(
            'This signature page was generated electronically upon submission of this dissertation in electronic format.', # rubocop:disable Layout/LineLength
            valign: :bottom
          )
        end
      end
    end

    # Draw the page number as a Roman numeral in the footer
    document.draw_text('iii', at: [190, -40], size: 8)
  end

  def copyright_year
    submitted_at&.year&.to_s || degreeconfyr
  end
end
