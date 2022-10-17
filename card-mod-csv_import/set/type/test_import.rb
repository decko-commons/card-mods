include_set Type::File
include_set Abstract::Import

# following shouldn't be necessary.  handle in Abstract::Import
attachment :test_import, uploader: CarrierWave::FileCardUploader

def import_item_class
  TestImportItem
end
