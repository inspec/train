require 'helper'
require 'train/transports/mock'
require 'train/file/remote/unix'

describe Train::File::Remote::Unix do
  let(:cls) { Train::File::Remote::Unix }

  let(:backend) {
    backend = Train::Transports::Mock.new.connection
    backend.mock_os({ family: 'linux' })
    backend
  }

  def mockup(stubs)
    Class.new(cls) do
      stubs.each do |k,v|
        define_method k.to_sym do
          v
        end
      end
    end.new(nil, nil, false)
  end

  describe 'unix_mode_mask' do
    let(:fc) { mockup(type: :file) }

    it 'check owner mode calculation' do
      fc.unix_mode_mask('owner', 'x').must_equal 0100
      fc.unix_mode_mask('owner', 'w').must_equal 0200
      fc.unix_mode_mask('owner', 'r').must_equal 0400
    end

    it 'check group mode calculation' do
      fc.unix_mode_mask('group', 'x').must_equal 0010
      fc.unix_mode_mask('group', 'w').must_equal 0020
      fc.unix_mode_mask('group', 'r').must_equal 0040
    end

    it 'check other mode calculation' do
      fc.unix_mode_mask('other', 'x').must_equal 0001
      fc.unix_mode_mask('other', 'w').must_equal 0002
      fc.unix_mode_mask('other', 'r').must_equal 0004
    end

    it 'check all mode calculation' do
      fc.unix_mode_mask('all', 'x').must_equal 0111
      fc.unix_mode_mask('all', 'w').must_equal 0222
      fc.unix_mode_mask('all', 'r').must_equal 0444
    end
  end

  describe '#md5sum' do
    let(:md5_checksum) { '57d4c6f9d15313fd5651317e588c035d' }

    let(:ruby_md5_mock) do
      checksum_mock = mock
      checksum_mock.expects(:update).returns('')
      checksum_mock.expects(:hexdigest).returns(md5_checksum)
      checksum_mock
    end

    it 'defaults to a Ruby based checksum if other methods fail' do
      backend.mock_command('md5 -r /tmp/testfile', '', '', 1)
      Digest::MD5.expects(:new).returns(ruby_md5_mock)
      cls.new(backend, '/tmp/testfile').md5sum.must_equal md5_checksum
    end


    it 'calculates the correct md5sum on the `darwin` platform family' do
      output = "#{md5_checksum} /tmp/testfile"
      backend.mock_os(family: 'darwin')
      backend.mock_command('md5 -r /tmp/testfile', output)
      cls.new(backend, '/tmp/testfile').md5sum.must_equal md5_checksum
    end

    it 'calculates the correct md5sum on the `solaris` platform family' do
      # The `digest` command doesn't output the filename by default
      output = "#{md5_checksum}"
      backend.mock_os(family: 'solaris')
      backend.mock_command('digest -a md5 /tmp/testfile', output)
      cls.new(backend, '/tmp/testfile').md5sum.must_equal md5_checksum
    end
  end

  describe '#sha256sum' do
    let(:sha256_checksum) {
      '491260aaa6638d4a64c714a17828c3d82bad6ca600c9149b3b3350e91bcd283d'
    }

    let(:ruby_sha256_mock) do
      checksum_mock = mock
      checksum_mock.expects(:update).returns('')
      checksum_mock.expects(:hexdigest).returns(sha256_checksum)
      checksum_mock
    end

    it 'defaults to a Ruby based checksum if other methods fail' do
      backend.mock_command('shasum -a 256 /tmp/testfile', '', '', 1)
      Digest::SHA256.expects(:new).returns(ruby_sha256_mock)
      cls.new(backend, '/tmp/testfile').sha256sum.must_equal sha256_checksum
    end


    it 'calculates the correct sha256sum on the `darwin` platform family' do
      output = "#{sha256_checksum} /tmp/testfile"
      backend.mock_os(family: 'darwin')
      backend.mock_command('shasum -a 256 /tmp/testfile', output)
      cls.new(backend, '/tmp/testfile').sha256sum.must_equal sha256_checksum
    end

    it 'calculates the correct sha256sum on the `solaris` platform family' do
      # The `digest` command doesn't output the filename by default
      output = "#{sha256_checksum}"
      backend.mock_os(family: 'solaris')
      backend.mock_command('digest -a sha256 /tmp/testfile', output)
      cls.new(backend, '/tmp/testfile').sha256sum.must_equal sha256_checksum
    end
  end
end
