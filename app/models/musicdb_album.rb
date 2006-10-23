class MusicdbAlbum < ActiveRecord::Base
  belongs_to :user
  def save # {{{
    self.timestamp = Time.now.to_i
    super
  end # }}}
end
