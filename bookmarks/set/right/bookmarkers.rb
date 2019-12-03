# cache # of users tagged with this metric/topic/whatever(=left)
# via <user>+bookmark
include_set Abstract::TaggedByCachedCount, type_to_count: :user,
            tag_pointer: :bookmark