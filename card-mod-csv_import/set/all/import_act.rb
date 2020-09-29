def import_act?
  act_card&.import_file?
end

# for override
def import_file?
  false
end
