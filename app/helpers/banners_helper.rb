module BannersHelper

  def link_to_random_banner
    banners = [
      { :img => 'http://www.publinews.it/bicoccaperlapace/bicoccaperlapace.jpg',           :url => 'http://asb.studentibicocca.it/pace/' },
      { :img => 'http://asb.studentibicocca.it/export/menu/img-menu/counseling.png',       :url => 'http://asb.studentibicocca.it/counseling.php' },
      { :img => 'http://asb.studentibicocca.it/export/menu/img-menu/concorsofoto.jpg',     :url => 'http://concorsofoto.studentibicocca.it' },
      { :img => 'http://asb.studentibicocca.it/export/menu/img-menu/conferenze.jpg',       :url => 'http://asb.studentibicocca.it/conferenze.php' },
      { :img => 'http://asb.studentibicocca.it/export/menu/img-menu/aperitivo.jpg',        :url => 'http://asb.studentibicocca.it/socializzazione.php' },
      { :img => 'http://asb.studentibicocca.it/export/menu/img-menu/festeinbicocca.jpg',   :url => 'http://feste.studentibicocca.it' },
      { :img => 'http://asb.studentibicocca.it/export/menu/img-menu/cineforumbicocca.gif', :url => 'http://cineforum.studentibicocca.it' },
    ]
    banner = banners[(banners.size * rand).to_i]
    link_to(image_tag(banner[:img]), banner[:url])
  end

end
