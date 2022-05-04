# this file is a little strange.
#
# It is necessary to have a new file in the search directory rather than adding
# #include_set directly to search.rb, because this makes it so that
# extra_paging_path_args overrides the code in search/search_params.

include_set Filter
