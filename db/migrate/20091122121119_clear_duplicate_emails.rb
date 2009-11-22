class ClearDuplicateEmails < ActiveRecord::Migration
  def self.up
    conn = User.connection
    conn.execute "CREATE TEMPORARY TABLE duplicate_emails
      SELECT email, count(1) count FROM xmb_users
      WHERE email != ''
      GROUP BY email
      HAVING count > 1
      ORDER BY uid"
    conn.execute "UPDATE xmb_users u
      INNER JOIN duplicate_emails d ON u.email = d.email
      SET u.email = CONCAT('+ ', u.email)
      WHERE postnum = 0"
    conn.execute "UPDATE xmb_users u
      SET u.email = NULL
      WHERE email = ''"
    conn.execute "DROP TEMPORARY TABLE duplicate_emails"
    # XXX I'm being real lazy here. The true solution to this problem would be
    # sending an e-mail with a password reminder to each duplicate address, but
    # then I'd be running into GMail's daily e-mail cap, and thus should split
    # the mass-mailing campaign over several days. This is kinda beyond the
    # scope of a quick fix, so I'm keeping the information for better days.
  end

  def self.down
  end
end
