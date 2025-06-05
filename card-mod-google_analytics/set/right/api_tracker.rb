include_set Abstract::AccountField

# allow account owner to create setting
def ok_to_create?
  own_account? || super
end

def ok_to_read?
  own_account? || super
end

format :html do
  view :status, unknown: true, template: :haml
end
