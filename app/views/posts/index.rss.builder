xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "#{SETTINGS[:site][:name]}: Posts"
    xml.link request.url
    xml.description "These are posts published at #{SETTINGS[:site][:name]}"
    xml.language "en-us"
    parse_xml_created_at(xml, @posts)
    @posts.each do |post|
      apply_fragment ['posts_rss_', post] do 
        xml.item do
          xml.title post.title
          xml.author (post.profile && post.profile.show_profile_link? ? post.profile.user_name : "HablaGuate")
          xml.description truncate_words(strip_tags(post.excerpt?), 50) 
          xml.created_at post.created_at.to_s(:rfc822)
          xml.link post_path(post, {:only_path=>false})
        end
      end
    end
  end
end

