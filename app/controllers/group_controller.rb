class GroupController < ApplicationController
	def list # {{{
		@groups = Group.find :all, :order => 'name'
	end # }}}
end
