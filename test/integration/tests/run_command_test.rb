# encoding: utf-8

describe "run_command" do
  let(:backend) { get_backend.call }

  it "can echo commands" do
    res = backend.run_command("echo hello world")
    _(res.stdout).must_equal("hello world\n")
    _(res.stderr).must_equal("")
    _(res.exit_status).must_equal(0)
  end

  it "can run frozen commands" do
    res = backend.run_command("echo hello world".freeze)
    _(res.stdout).must_equal("hello world\n")
    _(res.stderr).must_equal("")
    _(res.exit_status).must_equal(0)
  end

  it "can echo commands to stderr" do
    # TODO: Specinfra often fails on this test.
    # Fix and re-enable it.
    res = backend.run_command(">&2 echo hello world")
    _(res.stdout).must_equal("")
    _(res.stderr).must_equal("hello world\n")
    _(res.exit_status).must_equal(0)
  end

  it "prints a correct exit status" do
    res = backend.run_command("exit 123")
    _(res.stdout).must_equal("")
    _(res.stderr).must_equal("")
    _(res.exit_status).must_equal(123)
  end
end
