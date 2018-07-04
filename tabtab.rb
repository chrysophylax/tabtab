#!/usr/bin/env ruby
require_relative "lexer"

def output_file?
  if ARGV[1]
    $stdout.reopen(ARGV[1].to_s, "w")
  end
end

def load_file
  fname = ARGV[0].to_s
  raise "No file was given" unless File.exist?(fname)
  raise "File not readable" unless File.readable?(fname)
  fdata = IO.read(fname)
end

tabtab = Tabtab::Lexer.new
output_file?
puts tabtab.gen_table(load_file)

