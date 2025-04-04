require 'rsolr'
require 'yaml'

y = YAML.load_file("conn_info.yml")

solr = RSolr.connect :url => "https://admin:#{y["solrpw"]}@ciaindex2.britishart.yale.edu/solr/ycba_blacklight_dev"
response = solr.post "select", :params => {
    #:fq=>"recordtype_ss:\"lido\" && id:\"tms:5005\"",:wt=>"json", :sort=>"id desc", :fl=>"id",:rows=>5
    :fq=>"recordtype_ss:\"lido\" && has_image_ss:\"available\"",:wt=>"json", :sort=>"id desc", :fl=>"id",:rows=>100000
}
ids = Array.new
response['response']['docs'].each do |r|
  ids.push(r["id"].sub("tms:",""))
end
#puts ids

objectID = 9990
puts "objectID #{objectID}"
if ids.include?(objectID.to_s)
  puts "add <lido:resourceWrap> to xml"
else
  puts "don't add anything"
end
