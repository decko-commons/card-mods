# Abstract::ListRefCachedCount needs to know which items have been changed.
# But the standard ActiveModel dirty/mutations mechanism for this is not serializable
# and therefore cannot be thus preserved for delayed jobs (when the cached counting
# now takes place.)
#
# In the long term it would be preferable to have a more general solution, but for
# now we are just stashing

Card.action_specific_attributes << :changed_item_names

# make these available in delayed jobs
event :stash_changed_item_names, :after_integrate do
  @changed_item_names = changed_item_names.map(&:to_s)
end

def changed_item_names
  if @changed_item_names
    @changed_item_names.map(&:to_name)
  else
    dropped_item_names + added_item_names
  end
end
