#cb.rb
#/Users/rick/Dropbox/Projects/DS_Synthetic_Derivative/Controls/Proc
#run from Cases
#
def pbcopy(input)
  str = input.to_s
  IO.popen('pbcopy', 'w') { |f| f << str }
  str
end

def pbpaste
  `pbpaste`
end
pos=0
skip=TRUE
prefix='ds_studyid'
f = File.new("../Data/#{prefix}.txt")
prefix='ds'
f.each do |line|  
 #break if pos > 50
 line=line[0,8]
# puts line
 if line != '23273092' && skip 
	puts line,"skipping"
	next
 else
	skip=FALSE
 end
 pos+=1
 pbcopy(line)
 fname="Cases/#{prefix}_#{line}.txt"
 print "#{pos} #{line}"
 #print 
 STDIN.gets 
 s=pbpaste
 fname=fname.chomp
 #puts s
 if s != line
   print  "#{pos} #{fname} GOT clipboard\n"
   g=File.new(fname,'w') 
   g.write( s)
   g.close
 else
   print  "#{pos} #{fname} clipboard EMPTY\n"
 end
 s=''
end
f.close
