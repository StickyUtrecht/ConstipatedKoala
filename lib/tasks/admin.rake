namespace :admin do
  require 'rest_client'

  desc "Finds study progress for all members and updates the DB"
  task :studystatus, [:username, :password] => :environment do |t, args|

    Open3.popen3("/usr/local/bin/studystatus",
                 "--username", args[:username],
                 "--password", args[:password]) do |i, o, e, t|

      Member.all.each do |member|
        i.puts member.student_id
      end
      i.close
      while line = o.gets do
        puts line
      end
    end

  end

end
