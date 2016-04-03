#!/usr/bin/env ruby

require 'mechanize'
require 'open-uri'

@base_path = File.dirname(__FILE__)

SECTIONS = ['aws-nav-flyout-3-doc-compute', 'aws-nav-flyout-3-doc-storage', 'aws-nav-flyout-3-doc-databases',
  'aws-nav-flyout-3-doc-networking', 'aws-nav-flyout-3-doc-developer', 'aws-nav-flyout-3-doc-managementtools' ,
  'aws-nav-flyout-3-doc-security-identity', 'aws-nav-flyout-3-doc-analytics', 'aws-nav-flyout-3-doc-iot',
  'aws-nav-flyout-3-doc-gamedev', 'aws-nav-flyout-3-doc-mobile', 'aws-nav-flyout-3-doc-app', 'aws-nav-flyout-3-doc-enterprise']
@mechanize = Mechanize.new

def parse_main_page
  base_page = @mechanize.get('http://aws.amazon.com/documentation/')

  SECTIONS.each do |section|
    section_div = base_page.at('#' + section).search('.aws-link')
    section_div.each do |element|
      parse_sub_page(element.search('a')[0]["href"], element.text.strip)
    end
  end
end

def parse_sub_page(url, name)
  puts url
  puts name
  download_dir = "#{@base_path}/#{name.gsub(/[\x00\/\\:\*\?\"<>\|]/, '_')}"
  puts download_dir
  unless File.exist?(download_dir)
    Dir.mkdir(download_dir)
    sub_page = @mechanize.get(url)
    pdfs = sub_page.links_with(:href => /^\S*(.pdf)$/, :text => "PDF")
    if pdfs
      pdfs.each do |pdf|
        download = open("#{pdf.href}")
        IO.copy_stream(download, "#{download_dir}/#{File.basename(pdf.href)}")
      end
    end
  end
end

parse_main_page
