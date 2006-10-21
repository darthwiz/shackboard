class ThemeController < ApplicationController
  def test# {{{
    @theme = Theme.find_by_name("studentibicocca")
  end# }}}
end
