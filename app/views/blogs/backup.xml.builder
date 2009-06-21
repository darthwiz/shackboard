xml.blogs {
  @blogs.each { |blog|
    xml.blog {
      blog.attributes.each { |key, value| xml.tag! key.to_sym, value }
      xml.posts {
        blog.blog_posts.each { |post|
          xml.post {
            post.attributes.each { |key, value| xml.tag! key.to_sym, value }
            xml.comments {
              post.blog_comments.each { |comment|
                xml.comment {
                  comment.attributes.each { |key, value| xml.tag! key.to_sym, value }
                }
              }
            }
          }
        }
      }
    }
  }
}
