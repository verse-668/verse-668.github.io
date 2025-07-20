# scripts/generate.rb
require "json"
require "fileutils"

PAIRS = { "1"=>0, "8"=>1, "6"=>2, "*" =>3, "-" =>4, "T"=>5, "K"=>6, "S"=>7 }
ALPH  = %q(abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' ,".?*@#^-_)

def decode(s)
  s.scan(/../).map { |p| ALPH[PAIRS[p[0]] * 8 + PAIRS[p[1]]] }.join
end

data = JSON.parse(File.read("_data/verses.json"))
FileUtils.rm_rf(%w[_passages _verses _strands])
FileUtils.mkdir_p(%w[_passages _verses _strands])

data.each do |strand, passages|
  File.write("_strands/#{strand}.md", <<~M)
  ---
  strand: #{strand}
  layout: strand
  permalink: /#{strand}/
  title: "#{strand}"
  ---
  M

  passages.each do |pkey, parts|
    pnum = pkey.delete_prefix(strand).to_i

    File.write("_passages/#{strand}-#{pnum}.md", <<~M)
    ---
    strand: #{strand}
    passage: #{pnum}
    layout: passage
    permalink: /#{strand}/#{pnum}/
    title: "#{strand} #{pnum}"
    ---
    M

    verse_counter = 0
    parts.each_with_index do |enc_list, part_idx|
      enc_list.each do |enc|
        verse_counter += 1
        txt = decode(enc)
        File.write("_verses/#{strand}-#{pnum}-#{verse_counter}.md", <<~M)
        ---
        strand: #{strand}
        passage: #{pnum}
        part: #{part_idx}
        verse: #{verse_counter}
        layout: verse
        title: "#{strand} #{pnum}:#{verse_counter}"
        permalink: /#{strand}/#{pnum}/#{verse_counter}/
        ---
        #{txt}
        M
      end
    end
  end
end