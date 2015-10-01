# Redmine Git Branch Display

This Redmine 2.x plugin displays the repo identifier and git branch name on the associated revisions.

It caches the branches a revision is on for each changeset. The cache is considered stale when the
list of repo heads changes and is then refreshed on the next page load. So, the initial page load for
tickets with lots of commits can be noticeably slower, but the hook processing is not impacted.

## Screenshot
![Screenshot](http://content.screencast.com/users/colinmollenhour/folders/Jing/media/16c3f751-ec90-465f-840e-7360da646b56/2015-10-01_1015.png)

## Installation

1. Clone repo to /plugins directory.
2. Apply the following patch to Redmine code (try `patch -p0 < file.diff`):
```
--- a/app/models/repository/git.rb
+++ b/app/models/repository/git.rb
@@ -140,6 +140,9 @@ class Repository::Git < Repository
     end
     return if prev_db_heads.sort == repo_heads.sort

+    # Update heads_hash, used by redmine_gitbranchdisplay plugin
+    h["heads_hash"] = Digest::MD5.hexdigest(repo_heads.sort.join('|'))
+
     h["db_consistent"]  ||= {}
     if changesets.count == 0
       h["db_consistent"]["ordering"] = 1
@@ -149,6 +152,9 @@ class Repository::Git < Repository
       h["db_consistent"]["ordering"] = 0
       merge_extra_info(h)
       self.save
+    else
+      merge_extra_info(h)
+      self.save
     end
     save_revisions(prev_db_heads, repo_heads)
   end
@@ -235,7 +241,9 @@ class Repository::Git < Repository
     h1 = extra_info || {}
     h  = h1.dup
     h["branches"] ||= {}
-    h['branches'].map{|br, hs| hs['last_scmid']}
+    # See #12505 - 'git push -f' causes fatal error during fetch_changesets without this patch
+    #h['branches'].map{|br, hs| hs['last_scmid']}
+    h['branches'].map{|br, hs| hs['last_scmid'] if branches.include? br}.compact
   end

   def latest_changesets(path,rev,limit=10)
```

3. Run the usual `rake db:migrate_plugins`.
