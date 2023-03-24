'''
Renames files inside a folder with the parent folder string prepended
'''

indir=$1
for i in $(find "$indir" -type d); do
  subj=$(echo $i/* | rev | cut -d'/' -f2 | rev)
  orig_file=$(ls $i/*)
  filename=$(echo $orig_file | rev | cut -d'/' -f1 | rev )
  echo $subj
  echo $orig_file
  echo $filename
  newname=./${subj}_${filename}
  echo renaming to "$newname"  
  mv $orig_file ${newname}
  #rm -r ./.
done
