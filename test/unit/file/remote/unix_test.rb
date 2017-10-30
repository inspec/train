require 'helper'
require 'train/file/remote/unix'

describe Train::File::Remote::Unix do
  let(:cls) { Train::File::Remote::Unix }  

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
end  
