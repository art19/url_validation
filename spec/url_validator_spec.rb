# frozen_string_literal: true

require 'spec_helper'

class Record
  extend ActiveModel::Translation
  include ActiveModel::Validations
  attr_accessor :field
end

describe UrlValidator do
  let(:record) { Record.new }

  context 'without :scheme' do
    context 'when :allow_nil is set' do
      let(:validator) { described_class.new(attributes: [:field], allow_nil: true) }

      before { validator.validate_each(record, :field, nil) }

      it 'allows nil' do
        expect(record.errors).to be_empty
      end
    end

    context 'when :allow_blank is set' do
      let(:validator) { described_class.new(attributes: [:field], allow_blank: true) }

      before { validator.validate_each(record, :field, '') }

      it 'allows ""' do
        expect(record.errors).to be_empty
      end
    end

    context 'when nothing is set' do
      let(:validator) { described_class.new(attributes: [:field]) }

      context 'with a space' do
        before { validator.validate_each(record, :field, 'http://foo bar baz') }

        it 'does not allow' do
          expect(record.errors[:field].first).to include('invalid_url')
        end
      end

      context 'with tabs' do
        before { validator.validate_each(record, :field, 'http://foo bar   baz') }

        it 'does not allow tabs' do
          expect(record.errors[:field].first).to include('invalid_url')
        end
      end
    end
  end

  context 'with :scheme' do
    context 'when :scheme is set to http' do
      let(:validator) { described_class.new(attributes: [:field], scheme: 'http') }

      context 'with http url' do
        before { validator.validate_each(record, :field, 'http://www.apple.com') }

        it { expect(record.errors).to be_empty }
      end

      context 'with https url' do
        before { validator.validate_each(record, :field, 'https://www.apple.com') }

        it { expect(record.errors[:field].first).to include('invalid_url') }
      end
    end

    context 'when :scheme is set to %w( http https )' do
      let(:validator) { described_class.new(attributes: [:field], scheme: %w[http https]) }

      context 'with http' do
        before { validator.validate_each(record, :field, 'http://www.apple.com') }

        it { expect(record.errors).to be_empty }
      end

      context 'with https' do
        before { validator.validate_each(record, :field, 'https://www.apple.com') }

        it { expect(record.errors).to be_empty }
      end

      context 'with ftp' do
        before { validator.validate_each(record, :field, 'ftp://www.apple.com') }

        it { expect(record.errors[:field].first).to include('invalid_url') }
      end
    end

    context 'when :default_scheme is set' do
      let(:validator) { described_class.new(attributes: [:field], scheme: 'http', default_scheme: 'http') }

      before { validator.validate_each(record, :field, 'www.apple.com') }

      it 'tries a default scheme if :default_scheme is set' do
        expect(record.errors).to be_empty
      end
    end
  end

  context 'with garbage URLs that still somehow pass the ridiculously open-ended RFC' do
    let(:validator) { described_class.new(attributes: [:field]) }

    before do
      record.errors.clear
    end

    %w[http:sdg.sdfg/ http/sdg.d http:://dsfg.dsfg/ http//sdg..g http://://sdfg.f].each do |junk_uri|
      context "with #{junk_uri}" do
        before { validator.validate_each(record, :field, junk_uri) }

        it { expect(record.errors[:field].first).to include('invalid_url') }
      end
    end
  end

  context 'when checking for accessibility' do
    context 'without :check_host' do
      let(:validator) { described_class.new(attributes: [:field]) }

      before { validator.validate_each(record, :field, 'http://www.invalid.tld') }

      it { expect(record.errors).to be_empty }
    end

    context 'when :check_host set to true' do
      let(:validator) { described_class.new(attributes: [:field], check_host: true) }

      before { validator.validate_each(record, :field, 'http://www.invalid.tld') }

      it { expect(record.errors[:field].first).to include('url_not_accessible') }
    end

    context 'when :check_host set to http' do
      let(:validator) { described_class.new(attributes: [:field], check_host: 'http') }

      context 'when URL scheme is not http' do
        before { validator.validate_each(record, :field, 'https://www.invalid.tld') }

        it { expect(record.errors).to be_empty }
      end

      context 'when URL scheme is http' do
        before { validator.validate_each(record, :field, 'http://www.invalid.tld') }

        it { expect(record.errors[:field].first).to include('url_not_accessible') }
      end
    end

    context 'when :check_host is set to %w(http https)' do
      let(:validator) { described_class.new(attributes: [:field], check_host: %w[http https], scheme: %w[ftp http https]) }

      context 'when URL scheme is not http(s)' do
        before { validator.validate_each(record, :field, 'ftp://www.invalid.tld') }

        it { expect(record.errors).to be_empty }
      end

      context 'when URL scheme is http' do
        before { validator.validate_each(record, :field, 'http://www.invalid.tld') }

        it { expect(record.errors[:field].first).to include('url_not_accessible') }
      end

      context 'when URL scheme is https' do
        before { validator.validate_each(record, :field, 'https://www.invalid.tld') }

        it { expect(record.errors[:field].first).to include('url_not_accessible') }
      end
    end

    context 'when :check_host is set to true' do
      let(:validator) { described_class.new(attributes: [:field], check_host: true) }

      before { validator.validate_each(record, :field, 'http://www.google.com/sdgsdgf') }

      it { expect(record.errors).to be_empty }
    end

    context 'when using :check_path' do
      before { validator.validate_each(record, :field, 'http://www.google.com/sdgsdgf') }

      context 'with check_path: 404' do
        let(:validator) { described_class.new(attributes: [:field], check_path: 404) }

        it { expect(record.errors[:field].first).to include('url_invalid_response') }
      end

      context 'with check_path: 405' do
        let(:validator) { described_class.new(attributes: [:field], check_path: 405) }

        it { expect(record.errors[:field]).to be_empty }
      end

      context 'with check_path: :not_found' do
        let(:validator) { described_class.new(attributes: [:field], check_path: :not_found) }

        it { expect(record.errors[:field].first).to include('url_invalid_response') }
      end

      context 'with check_path: :unauthorized' do
        let(:validator) { described_class.new(attributes: [:field], check_path: :unauthorized) }

        it { expect(record.errors[:field]).to be_empty }
      end

      context 'with check_path: 400..499' do
        let(:validator) { described_class.new(attributes: [:field], check_path: 400..499) }

        it { expect(record.errors[:field].first).to include('url_invalid_response') }
      end

      context 'with check_path: 500..599' do
        let(:validator) { described_class.new(attributes: [:field], check_path: 500..599) }

        it { expect(record.errors[:field]).to be_empty }
      end

      context 'with check_path: [404,405]' do
        let(:validator) { described_class.new(attributes: [:field], check_path: [404, 405]) }

        it { expect(record.errors[:field].first).to include('url_invalid_response') }
      end

      context 'with check_path: [405, 406]' do
        let(:validator) { described_class.new(attributes: [:field], check_path: [405, 406]) }

        it { expect(record.errors[:field]).to be_empty }
      end

      context 'with check_path: %i[not_found unauthorized]' do
        let(:validator) { described_class.new(attributes: [:field], check_path: %i[not_found unauthorized]) }

        it { expect(record.errors[:field].first).to include('url_invalid_response') }
      end

      context 'with check_path: %[unauthorized moved_permanently]' do
        let(:validator) { described_class.new(attributes: [:field], check_path: %i[unauthorized moved_permanently]) }

        it { expect(record.errors[:field]).to be_empty }
      end

      context 'when check_path is an array of ranges and response code in range' do
        let(:validator) { described_class.new(attributes: [:field], check_path: [400..499, 500..599]) }

        it { expect(record.errors[:field].first).to include('url_invalid_response') }
      end

      context 'when check_path is an array of ranges and response code NOT in range' do
        let(:validator) { described_class.new(attributes: [:field], check_path: [500..599, 300..399]) }

        it { expect(record.errors[:field]).to be_empty }
      end

      context 'when check_path is nil' do
        let(:validator) { described_class.new(attributes: [:field], check_path: nil) }

        it { expect(record.errors[:field]).to be_empty }
      end

      context 'when check_path is true' do
        let(:validator) { described_class.new(attributes: [:field], check_path: true) }

        it { expect(record.errors[:field].first).to include('url_invalid_response') }
      end
    end

    context 'with non-HTTP URLs' do
      let(:validator) { described_class.new(attributes: [:field], check_path: true, scheme: %w[ftp http https]) }

      before { validator.validate_each(record, :field, 'ftp://ftp.sdgasdgohaodgh.com/sdgjsdg') }

      it { expect(record.errors[:field]).to be_empty }
    end

    context 'when using httpi_adapter' do
      let(:validator) { described_class.new(attributes: [:field], httpi_adapter: :curl, check_host: true) }

      it 'uses the specified HTTPI adapter' do
        allow(HTTPI).to receive(:get).with(an_instance_of(HTTPI::Request), :curl).and_return(false)
        validator.validate_each(record, :field, 'http://www.google.com/sdgsdgf')

        expect(HTTPI).to have_received(:get).once
      end
    end

    context 'with :request_callback' do
      called = false
      let(:validator) do
        described_class.new(
          attributes:       [:field],
          check_host:       true,
          request_callback: lambda do |request|
            called = true
            expect(request).to be_kind_of(HTTPI::Request)
          end
        )
      end

      before { validator.validate_each(record, :field, 'http://www.google.com/sdgsdgf') }

      it 'is yielded the HTTPI request' do
        expect(called).to be(true)
      end
    end
  end
end
