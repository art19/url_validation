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

    %w(http:sdg.sdfg/ http/sdg.d http:://dsfg.dsfg/ http//sdg..g http://://sdfg.f).each do |junk_uri|
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

    context 'with :check_host' do
      it 'onlies validate if the host is accessible when :check_host is set' do
        validator = described_class.new(attributes: [:field], check_host: true)
        validator.validate_each(record, :field, 'http://www.invalid.tld')
        expect(record.errors[:field].first).to include('url_not_accessible')
      end

      it "does not perform the accessibility check if :check_host is set to 'http' and the URL scheme is not HTTP" do
        validator = described_class.new(attributes: [:field], check_host: 'http')
        validator.validate_each(record, :field, 'https://www.invalid.tld')
        expect(record.errors).to be_empty
      end

      it "onlies validate if the host is accessible when :check_host is set to 'http' and the URL scheme is HTTP" do
        validator = described_class.new(attributes: [:field], check_host: 'http')
        validator.validate_each(record, :field, 'http://www.invalid.tld')
        expect(record.errors[:field].first).to include('url_not_accessible')
      end

      it 'does not perform the accessibility check if :check_host is set to %w( http https ) and the URL scheme is not HTTP(S)' do
        validator = described_class.new(attributes: [:field], check_host: %w[http https], scheme: %w[ftp http https])
        validator.validate_each(record, :field, 'ftp://www.invalid.tld')
        expect(record.errors).to be_empty
      end

      it 'onlies validate if the host is accessible when :check_host is set to %w( http https ) and the URL scheme is HTTP(S)' do
        validator = described_class.new(attributes: [:field], check_host: %w[http https])
        validator.validate_each(record, :field, 'http://www.invalid.tld')
        expect(record.errors[:field].first).to include('url_not_accessible')

        validator = described_class.new(attributes: [:field], check_host: %w[http https])
        validator.validate_each(record, :field, 'https://www.invalid.tld')
        expect(record.errors[:field].first).to include('url_not_accessible')
      end

      it 'onlies validate the host' do
        validator = described_class.new(attributes: [:field], check_host: true)
        validator.validate_each(record, :field, 'http://www.google.com/sdgsdgf')
        expect(record.errors).to be_empty
      end
    end

    context '[:check_path]' do
      it 'does not validate if the response code is equal to the Fixnum value of this option' do
        validator = described_class.new(attributes: [:field], check_path: 404)
        validator.validate_each(record, :field, 'http://www.google.com/sdgsdgf')
        expect(record.errors[:field].first).to include('url_invalid_response')

        record.errors.clear

        validator = described_class.new(attributes: [:field], check_path: 405)
        validator.validate_each(record, :field, 'http://www.google.com/sdgsdgf')
        expect(record.errors[:field]).to be_empty
      end

      it 'does not validate if the response code is equal to the Symbol value of this option' do
        validator = described_class.new(attributes: [:field], check_path: :not_found)
        validator.validate_each(record, :field, 'http://www.google.com/sdgsdgf')
        expect(record.errors[:field].first).to include('url_invalid_response')

        record.errors.clear

        validator = described_class.new(attributes: [:field], check_path: :unauthorized)
        validator.validate_each(record, :field, 'http://www.google.com/sdgsdgf')
        expect(record.errors[:field]).to be_empty
      end

      it 'does not validate if the response code is within the Range value of this option' do
        validator = described_class.new(attributes: [:field], check_path: 400..499)
        validator.validate_each(record, :field, 'http://www.google.com/sdgsdgf')
        expect(record.errors[:field].first).to include('url_invalid_response')

        record.errors.clear

        validator = described_class.new(attributes: [:field], check_path: 500..599)
        validator.validate_each(record, :field, 'http://www.google.com/sdgsdgf')
        expect(record.errors[:field]).to be_empty
      end

      it 'does not validate if the response code is equal to the Fixnum value contained in the Array value of this option' do
        validator = described_class.new(attributes: [:field], check_path: [404, 405])
        validator.validate_each(record, :field, 'http://www.google.com/sdgsdgf')
        expect(record.errors[:field].first).to include('url_invalid_response')

        record.errors.clear

        validator = described_class.new(attributes: [:field], check_path: [405, 406])
        validator.validate_each(record, :field, 'http://www.google.com/sdgsdgf')
        expect(record.errors[:field]).to be_empty
      end

      it 'does not validate if the response code is equal to the Symbol value contained in the Array value of this option' do
        validator = described_class.new(attributes: [:field], check_path: %i[not_found unauthorized])
        validator.validate_each(record, :field, 'http://www.google.com/sdgsdgf')
        expect(record.errors[:field].first).to include('url_invalid_response')

        record.errors.clear

        validator = described_class.new(attributes: [:field], check_path: %i[unauthorized moved_permanently])
        validator.validate_each(record, :field, 'http://www.google.com/sdgsdgf')
        expect(record.errors[:field]).to be_empty
      end

      it 'does not validate if the response code is equal to the Range value contained in the Array value of this option' do
        validator = described_class.new(attributes: [:field], check_path: [400..499, 500..599])
        validator.validate_each(record, :field, 'http://www.google.com/sdgsdgf')
        expect(record.errors[:field].first).to include('url_invalid_response')

        record.errors.clear

        validator = described_class.new(attributes: [:field], check_path: [500..599, 300..399])
        validator.validate_each(record, :field, 'http://www.google.com/sdgsdgf')
        expect(record.errors[:field]).to be_empty
      end

      it 'skips validation by default' do
        validator = described_class.new(attributes: [:field], check_path: nil)
        validator.validate_each(record, :field, 'http://www.google.com/sdgsdgf')
        expect(record.errors[:field]).to be_empty
      end

      it 'does not validate 4xx and 5xx response codes if the value is true' do
        validator = described_class.new(attributes: [:field], check_path: true)
        validator.validate_each(record, :field, 'http://www.google.com/sdgsdgf')
        expect(record.errors[:field].first).to include('url_invalid_response')
      end

      it 'skips validation for non-HTTP URLs' do
        validator = described_class.new(attributes: [:field], check_path: true, scheme: %w[ftp http https])
        validator.validate_each(record, :field, 'ftp://ftp.sdgasdgohaodgh.com/sdgjsdg')
        expect(record.errors[:field]).to be_empty
      end
    end

    context '[:httpi_adapter]' do
      it 'uses the specified HTTPI adapter' do
        validator = described_class.new(attributes: [:field], httpi_adapter: :curl, check_host: true)
        expect(HTTPI).to receive(:get).once.with(an_instance_of(HTTPI::Request), :curl).and_return(false)
        validator.validate_each(record, :field, 'http://www.google.com/sdgsdgf')
      end
    end

    context '[:request_callback]' do
      called = false
      let(:validator) { described_class.new(attributes: [:field], check_host: true, request_callback: ->(request) { called = true; expect(request).to be_kind_of(HTTPI::Request) }) }

      before { validator.validate_each(record, :field, 'http://www.google.com/sdgsdgf') }

      it 'is yielded the HTTPI request' do
        expect(called).to be(true)
      end
    end
  end
end
