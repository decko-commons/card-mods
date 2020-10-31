def import_act?
  act_card&.import_file? || Env.params[:importing].present?
end

# for override
def import_file?
  false
end
