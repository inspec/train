# encoding: utf-8
require 'helper'
require 'train/extras'
require 'train/transports/mock'

describe 'stat' do
  let(:cls) { Train::Extras::Stat }

  describe 'find_type' do
    let (:random_mode) { (rand * 1000).to_i }

    it 'detects :unknown types' do
      cls.find_type(random_mode).must_equal :unknown
    end

    it 'detects sockets' do
      cls.find_type(00140755).must_equal :socket
    end

    it 'detects symlinks' do
      cls.find_type(00120755).must_equal :symlink
    end

    it 'detects files' do
      cls.find_type(00100755).must_equal :file
    end

    it 'detects block devices' do
      cls.find_type(00060755).must_equal :block_device
    end

    it 'detects directories' do
      cls.find_type(00040755).must_equal :directory
    end

    it 'detects character devices' do
      cls.find_type(00020755).must_equal :character_device
    end

    it 'detects pipes' do
      cls.find_type(00010755).must_equal :pipe
    end
  end

  describe 'linux stat' do
    let(:backend) {
      mock = Train::Transports::Mock.new(verbose: true).connection
      mock.mock_os({ name: 'ubuntu', family: 'debian', release: '15.04', arch: 'x86_64' })
      mock.commands = {
        "stat /path 2>/dev/null --printf '%s\n%f\n%U\n%u\n%G\n%g\n%X\n%Y\n%C'" => mock.mock_command('', '', '', 0),
        "stat /path-stat 2>/dev/null --printf '%s\n%f\n%U\n%u\n%G\n%g\n%X\n%Y\n%C'" => mock.mock_command('', "360\n43ff\nroot\n0\nrootz\n1\n1444520846\n1444522445\n?", '', 0),
      }
      mock
    }

    it 'ignores wrong stat results' do
      cls.linux_stat('/path', backend, false).must_equal({})
    end

    it 'reads correct stat results' do
      cls.linux_stat('/path-stat', backend, false).must_equal({
        type: :directory,
        mode: 01777,
        owner: 'root',
        uid: 0,
        group: 'rootz',
        gid: 1,
        mtime: 1444522445,
        size: 360,
        selinux_label: nil,
      })
    end
  end

  describe 'esx stat' do
    let(:backend) {
      mock = Train::Transports::Mock.new(verbose: true).connection
      mock.mock_os({ name: 'vmkernel', family: 'esx', release: '5' })
      mock.commands = {
        "stat /path 2>/dev/null -c '%s\n%f\n%U\n%u\n%G\n%g\n%X\n%Y\n%C'" => mock.mock_command('', '', '', 0),
        "stat /path-stat 2>/dev/null -c '%s\n%f\n%U\n%u\n%G\n%g\n%X\n%Y\n%C'" => mock.mock_command('', "360\n43ff\nroot\n0\nrootz\n1\n1444520846\n1444522445\n?", '', 0),
      }
      mock
    }

    it 'ignores wrong stat results' do
      cls.linux_stat('/path', backend, false).must_equal({})
    end

    it 'reads correct stat results' do
      cls.linux_stat('/path-stat', backend, false).must_equal({
        type: :directory,
        mode: 01777,
        owner: 'root',
        uid: 0,
        group: 'rootz',
        gid: 1,
        mtime: 1444522445,
        size: 360,
        selinux_label: nil,
      })
    end
  end

  describe 'alpine stat' do
    let(:backend) {
      mock = Train::Transports::Mock.new(verbose: true).connection
      mock.mock_os({ name: 'alpine', family: 'alpine', release: nil })
      mock.commands = {
        "stat /path 2>/dev/null -c '%s\n%f\n%U\n%u\n%G\n%g\n%X\n%Y\n%C'" => mock.mock_command('', '', '', 0),
        "stat /path-stat 2>/dev/null -c '%s\n%f\n%U\n%u\n%G\n%g\n%X\n%Y\n%C'" => mock.mock_command('', "360\n43ff\nroot\n0\nrootz\n1\n1444520846\n1444522445\n?", '', 0),
      }
      mock
    }

    it 'ignores wrong stat results' do
      cls.linux_stat('/path', backend, false).must_equal({})
    end

    it 'reads correct stat results' do
      cls.linux_stat('/path-stat', backend, false).must_equal({
        type: :directory,
        mode: 01777,
        owner: 'root',
        uid: 0,
        group: 'rootz',
        gid: 1,
        mtime: 1444522445,
        size: 360,
        selinux_label: nil,
      })
    end
  end

  describe 'bsd stat' do
    let(:backend) { Minitest::Mock.new }

    it 'ignores failed stat results' do
      res = Minitest::Mock.new
      res.expect :stdout, '.....'
      res.expect :exit_status, 1
      backend.expect :run_command, res, [String]
      cls.bsd_stat('/path', backend, false).must_equal({})
    end

    it 'ignores wrong stat results' do
      res = Minitest::Mock.new
      res.expect :stdout, ''
      res.expect :exit_status, 0
      backend.expect :run_command, res, [String]
      cls.bsd_stat('/path', backend, false).must_equal({})
    end

    it 'reads correct stat results' do
      res = Minitest::Mock.new
      res.expect :stdout, "360\n41777\nroot\n0\nrootz\n1\n1444520846\n1444522445"
      res.expect :exit_status, 0
      backend.expect :run_command, res, [String]
      cls.bsd_stat('/path', backend, false).must_equal({
        type: :directory,
        mode: 01777,
        owner: 'root',
        uid: 0,
        group: 'rootz',
        gid: 1,
        mtime: 1444522445,
        size: 360,
        selinux_label: nil,
      })
    end
  end

  describe 'aix stat' do
    let(:backend) { Minitest::Mock.new }

    it 'ignores failed stat results' do
      res = Minitest::Mock.new
      res.expect :stdout, '.....'
      res.expect :exit_status, 1
      backend.expect :run_command, res, [String]
      cls.aix_stat('/path', backend, false).must_equal({})
    end

    it 'ignores wrong stat results' do
      res = Minitest::Mock.new
      res.expect :stdout, ''
      res.expect :exit_status, 0
      backend.expect :run_command, res, [String]
      cls.aix_stat('/path', backend, false).must_equal({})
    end

    it 'reads correct stat results' do
      res = Minitest::Mock.new
      res.expect :stdout, "41777\nroot\n0\nrootz\n1\n1444522445\n360\n"
      res.expect :exit_status, 0
      backend.expect :run_command, res, [String]
      cls.aix_stat('/path', backend, false).must_equal({
        type: :directory,
        mode: 01777,
        owner: 'root',
        uid: 0,
        group: 'rootz',
        gid: 1,
        mtime: 1444522445,
        size: 360,
        selinux_label: nil,
      })
    end
  end
end
