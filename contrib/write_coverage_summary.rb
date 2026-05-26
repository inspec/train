#!/usr/bin/env ruby

require "json"
require "optparse"

options = {
  threshold: 80.0,
  step_outcome: "unknown",
}

OptionParser.new do |parser|
  parser.banner = "Usage: write_coverage_summary.rb [options]"

  parser.on("--coverage-file PATH", "Path to SimpleCov .last_run.json") do |value|
    options[:coverage_file] = value
  end

  parser.on("--test-output PATH", "Path to captured test output") do |value|
    options[:test_output] = value
  end

  parser.on("--summary-file PATH", "Path to output markdown summary") do |value|
    options[:summary_file] = value
  end

  parser.on("--threshold FLOAT", Float, "Soft coverage threshold") do |value|
    options[:threshold] = value
  end

  parser.on("--command TEXT", "Validation command to report") do |value|
    options[:command] = value
  end

  parser.on("--step-outcome TEXT", "GitHub Actions step outcome") do |value|
    options[:step_outcome] = value
  end
end.parse!

abort("Missing --summary-file") unless options[:summary_file]

coverage_value = nil
if options[:coverage_file] && File.exist?(options[:coverage_file])
  coverage_json = JSON.parse(File.read(options[:coverage_file]))
  coverage_value = coverage_json.dig("result", "line")
end

summary_lines = []
summary_lines << "## Advisory Coverage Summary"
summary_lines << ""

if coverage_value
  gate_status = coverage_value >= options[:threshold] ? "meets" : "is below"
  summary_lines << "- Coverage: #{format("%.2f", coverage_value)}%"
  summary_lines << "- Soft gate: #{gate_status} the #{format("%.2f", options[:threshold])}% threshold"
else
  summary_lines << "- Coverage: unavailable"
  summary_lines << "- Soft gate: could not be evaluated because coverage output was missing"
end

summary_lines << "- Validation step outcome: #{options[:step_outcome]}"
summary_lines << "- Advisory only: yes (workflow does not fail merges on coverage step failure)"
summary_lines << "- Command: `#{options[:command]}`" if options[:command]

if options[:test_output] && File.exist?(options[:test_output])
  output = File.read(options[:test_output])
  test_summary = output.lines.reverse.find { |line| line.match?(/\d+ runs, \d+ assertions, \d+ failures, \d+ errors, \d+ skips/) }
  duration_summary = output.lines.reverse.find { |line| line.start_with?("Finished in ") }

  summary_lines << ""
  summary_lines << "### Test Output"
  summary_lines << ""
  summary_lines << "- #{duration_summary.strip}" if duration_summary
  summary_lines << "- #{test_summary.strip}" if test_summary
end

File.write(options[:summary_file], summary_lines.join("\n") + "\n")
puts summary_lines.join("\n")
