require "spec_setup"
require "fpm" # local
require "fpm/package/deb" # local
require "fpm/package/dir" # local

describe FPM::Package::Deb do
  after :each do
    subject.cleanup
  end

  describe "#architecture" do
    it "should convert x86_64 to amd64" do
      subject.architecture = "x86_64"
      insist { subject.architecture } == "amd64"
    end

    it "should convert i386 to i686" do
      subject.architecture = "i386"
      insist { subject.architecture } == "i686"
    end

    it "should default to native" do
      expected = %x{uname -m}.chomp
      expected = "amd64" if expected == "x86_64"
      insist { subject.architecture } == expected
    end
  end

  describe "#output" do
    before :all do
      # output a package, use it as the input, set the subject to that input
      # package. This helps ensure that we can write and read packages
      # properly.
      tmpfile = Tempfile.new("fpm-test-deb")
      target = tmpfile.path
      # The target file must not exist.
      tmpfile.unlink

      @original = FPM::Package::Deb.new
      @original.name = "name"
      @original.version = "123"
      @original.iteration = "100"
      @original.epoch = "5"
      @original.dependencies << "something > 10"
      @original.dependencies << "hello >= 20"
      @original.output(target)

      @input = FPM::Package::Deb.new
      @input.input(target)
    end

    after :all do
      @original.cleanup
      @input.cleanup
    end # after

    context "package attributes" do
      it "should have the correct name" do
        insist { @input.name } == @original.name
      end

      it "should have the correct version" do
        insist { @input.version } == @original.version
      end

      it "should have the correct iteration" do
        insist { @input.iteration } == @original.iteration
      end

      it "should have the correct epoch" do
        insist { @input.epoch } == @original.epoch
      end

      it "should have the correct dependencies" do
        @original.dependencies.each do |dep|
          insist { @input.dependencies }.include?(dep)
        end
      end
    end
  end
end # describe FPM::Package::Deb