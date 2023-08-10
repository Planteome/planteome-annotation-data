# Annotations by object type

1. Go to the https://dev.planteome.org site once all annotations are loaded.
2. From the top toolbar: Search -> Annotations.
3. Click on "Object Type" in the left column.
4. Hightlight all object types with counts and right-click copy them to the clipboard.
5. Save them to a text file.
6. Use the following regex in vim to clean it up:
    `:%s/(//`
    `:%s/)//`
7. Use the following command to add the html table tags, format the numbers, and copy to the clipboard:
    `cat annot_by_type.tsv | numfmt --field=1 --g | awk '{print "<tr><td>"$2"</td><td>"$1"</td><td></td></tr>"}' | xclip -selection clipboard`
8. Create the page in drupal, add a 3x3 table via the toolbar.
9. Switch to "source" view, empty out the middle row (<tr> tag) and paste the table in.
10. Fill in the header and footer of the table with:
    Object type | # Annotations | Total # data objects by type (header)
    Total number of annotations/unique data objects (footer)
11. The 3rd column of the table is easy enough to just fill in by hand
    Go to "Search -> Bioentities" in the top toolbar and redo step 3.
12. To calculate the sum of all annotations:
    `cat annot_by_type.tsv | awk '{print $1}' | paste -sd+ | bc`
13. Save file with "Text format" "Full HTML".


# Annotations by source

1. Go to the https://dev.planteome.org site once all annotations are loaded.
2. From the top toolbar: Search -> Annotations.
3. Click on "Source" in the left column.
4. Click on "more" at the bottom to get the full list.
5. Highlight all sources with counts and right-click copy them to the clipboard.
6. Save them to a text file.
7. Use the following regex in vim to clean it up:
    `:%s/Ctrl-V<tab>+Ctrl-V<tab>-//` (Ctrl-V is a literal "Ctrl" button and V and <tab> is the tab buttton)
    `:%s/(//`
    `:%s/)//`
8. Use the following command to add the html table tags, format the numbers, and copy to the clipboard:
    `cat annot_by_source.tsv | numfmt --field=2 --g | awk '{print "<tr><td>"$1"</td><td>"$2"</td></tr>"}' | xclip -selection clipboard`
9. Create the page in drupal, add a 3x2 table via the toolbar.
10. Switch to "source" view, empty out the middle row (<tr> tag) and paste the table in.
11. Fill in the header and footer of the table with:
    Database: | Annotations
12. To calculate the sum of all annotations:
    `cat annot_by_source.tsv | awk '{print $2}' | paste -sd+ | bc`
13. Save file with "Text format" "Full HTML".


# Annotations by taxa

1. Go to the https://dev.planteome.org site once all annotations are loaded.
2. From the top toolbar: Search -> Annotations.
3. Click on "Taxon" in the left column.
4. Click on "more" at the bottom to get the full list.
5. Highlight all taxa with counts and right-click copy them to the clipboard.
6. Save them to a text file.
7. Use the following regex in vim to clean it up:
    `:%s/Ctrl-V<tab>+Ctrl-V<tab>-//`
    `:%s/(//`
    `:%s/)//`
8. Also need a file with the old "Annotations by taxa" from the previous release. Get it from the drupal page and copy/paste the table in to a file
9. The script to create the table is available at https://github.com/Planteome/planteome-annotation-data/blob/master/scripts/annot_by_taxa_release_notes.pl
    The "Number::Format" module is required.
10. Run the script with:
    `annot_by_taxa_release_notes.pl old_tsv_file new_tsv_file out_file`
11. Copy the contents of the out_file to a new drupal page with a 2x4 table
12. Switch to "source" view, empty out the last row and paste the output from the script in.
13. Fill in the header with:
    Species | Taxon ID | Common name | Annotations Total#
14. Go back to non-Source view and look for any empty table cells. New species will have to be manually entered for Taxon ID and common name.
15. Save file with "Text format" "Full HTML".