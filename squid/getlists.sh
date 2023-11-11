#!/bin/bash
#-----------------------------------------------------------------
#
# -- Changed - 15 June 2003
# --    Change 
#       "squidguard -C domains" to 
#       "squidguard -C all"
#       old way wasn't doing anything useful
#
#Below is the script that I use. You need to edit the first part
#to tell where your squid and squidguard binaries are, and also
#where your squidguard #blacklists are. This has the recent change
#of address for the squidguard.org-supplied blacklists.
#You will need to obtain and install the utility "wget" for this
#script to work. It is available as an RPM for RedHat. WGet is used
#to get the files. You can #use scripted ftp instead, but it's much
#more of a pain and less reliable.
#-----------------------------------------------------------------
# --------------------------------------------------------------
# Script to Update squidguard Blacklists
# Rick@Matthews.net with mods by morris@maynidea.com
# Last updated 05/31/2003
#
# This script downloads blacklists from two sites, merges and
# de-dupes them, then makes local changes (+/-). It does this
# in all of the categories (except porn) using the standard
# squidguard .diff files. The porn directory is handled
# differently, in part because of the large volume of changes.
#
# The user maintains local changes to the porn category in the
# files < domains_diff.local> and <urls_diff.local>. These files
# use the standard squidguard .diff file format:
# +domain_A.com
# -domain_B.com
#

# --------------------------------------------------------------
# Set date format for naming files

set -x

DATE=`date +%Y-%m-%d`
YEAR=`date +%Y`
DATETIME=`date +"%a %d %h %Y %T %Z"`
UNIQUEDT=`date +"%Y%m%d%H%M%S"`
#UNIQUEDT="xxx"
WGOPTS=-nv
WGOPTS=-v
echo ${UNIQUEDT}

# Give location of squid and squidguard programs
SQUID=/usr/sbin/squid
SQUIDGUARD=/usr/bin/squidGuard
# --------------------------------------------------------------
# BLACKDIR should be set to equal the dbhome path declaration
# in your squidguard.conf file
BLACKDIR=/var/lib/squidguard/db
BLKDIRADLT=${BLACKDIR}/blacklists
PORN=${BLACKDIR}/blacklists/porn
ADULT=${BLACKDIR}/blacklists/adult
ADS=${BLACKDIR}/blacklists/ads

# --------------------------------------------------------------
# Create statistics file for porn directory
#
mkdir -p ${PORN}/stats
mkdir -p ${PORN}/archive
mkdir -p ${ADULT}/stats
mkdir -p ${ADULT}/archive

touch ${PORN}/stats/${UNIQUEDT}_stats
echo "Blacklist Line Counts for "${DATETIME} \
  >> ${PORN}/stats/${UNIQUEDT}_stats

# --------------------------------------------------------------
# Download the latest blacklist from the squidguard site
#
# Uses wget (http://wget.sunsite.dk/)
#
# Downloads the current blacklist tar.gz file into the
# ${BLACKDIR} directory (defined above) and will name the file
# uniquely with today's date: ${UNIQUEDT}_sg.tar.gz
#

#CHANGED
#Original download:
wget ${WGOPTS} --output-document=${BLACKDIR}/${UNIQUEDT}_sg.tar.gz \
  ftp://ftp.univ-tlse1.fr/pub/reseau/cache/squidguard_contrib/blacklists.tar.gz

#wget ${WGOPTS} --output-document=${BLACKDIR}/${UNIQUEDT}_sg.tar.gz \
#  http://squidguard.mesd.k12.or.us/blacklists.tgz


#
# Download the latest adult.tar.gz file from the
# Universit� Toulouse in France (Seems to be updated daily)
#
# see http://cri.univ-tlse1.fr/documentations/cache/squidguard_en.html
#
# Uses wget (http://wget.sunsite.dk/)
#
# Download the current adult.tar.gz file into the
# ${BLACKDIR} directory (defined above) and will name the file
# uniquely with today's date: ${UNIQUEDT}_fr.tar.gz
#
# If you are inside of a firewall you may need passive ftp.
# For passive ftp change the wget line below to read:
# wget --passive-ftp --output-document=${BLACKDIR}/${UNIQUEDT}_fr.tar.gz \
#

wget ${WGOPTS} --output-document=${BLACKDIR}/${UNIQUEDT}_fr.tar.gz \
  ftp://ftp.univ-tlse1.fr/pub/reseau/cache/squidguard_contrib/adult.tar.gz

# --------------------------------------------------------------
# Install the new squidguard blacklist
#
# Installs the blacklist under the ${BLACKDIR} directory:
#   ${BLACKDIR}/blacklists/ads
# ${BLACKDIR}/blacklists/aggressive
# ${BLACKDIR}/blacklists/audio-video
# ${BLACKDIR}/blacklists/drugs
# ${BLACKDIR}/blacklists/gambling
# ${BLACKDIR}/blacklists/hacking
# ${BLACKDIR}/blacklists/mail
# ${BLACKDIR}/blacklists/porn
# ${BLACKDIR}/blacklists/proxy
# ${BLACKDIR}/blacklists/violence
# ${BLACKDIR}/blacklists/warez
#

gunzip < ${BLACKDIR}/${UNIQUEDT}_sg.tar.gz | (cd ${BLACKDIR}; tar xvf -)

# --------------------------------------------------------------
# Remove the differential diff files that are supplied with the
# squidguard blacklists - they are simply clutter
#

rm -f ${PORN}/domains.*.diff
rm -f ${PORN}/urls.*.diff
rm -f ${ADS}/domains.*.diff
rm -f ${ADS}/urls.*.diff

# --------------------------------------------------------------
# Remove the comment lines from the ${PORN}/domains and
# ${PORN}/urls files so they can be sorted
#

grep -v -e '^#' ${PORN}/domains > ${PORN}/domains.temp
mv -f ${PORN}/domains.temp ${PORN}/domains

grep -v -e '^#' ${PORN}/urls > ${PORN}/urls.temp
mv -f ${PORN}/urls.temp ${PORN}/urls

# --------------------------------------------------------------
# Log item counts to porn statistics file
#

echo " " >> ${PORN}/stats/${UNIQUEDT}_stats
echo "Squidguard blacklist files as downloaded" \
  >> ${PORN}/stats/${UNIQUEDT}_stats
echo "----------------------------------------" \
  >> ${PORN}/stats/${UNIQUEDT}_stats

wc --lines ${PORN}/domains >> ${PORN}/stats/${UNIQUEDT}_stats
wc --lines ${PORN}/urls >> ${PORN}/stats/${UNIQUEDT}_stats

# --------------------------------------------------------------
# Install the new adult blacklist from Universit� Toulouse
#
# Installs the blacklist under the ${BLKDIRADLT} directory:
#   ${BLKDIRADLT}/adult
#
# Also cleans up any entries that begin with a dash (-)
#

# gunzip < ${BLACKDIR}/${UNIQUEDT}_fr.tar.gz | (cd ${BLACKDIR}; tar xvf -)
# tar -C ${BLKDIRADLT} -xvzf ${BLACKDIR}/${UNIQUEDT}_fr.tar.gz
# perl -pi -e "s#^\-##g" ${BLKDIRADLT}/adult/domains
# perl -pi -e "s#^\-##g" ${BLKDIRADLT}/adult/urls

# --------------------------------------------------------------
# Save current files for subsequent processing
# Age older files
# The most recent files will always be domains.0 and urls.0
#

[ -f ${PORN}/archive/domains.-2 ] && mv -f ${PORN}/archive/domains.-2 ${PORN}/archive/domains.-3
[ -f ${PORN}/archive/urls.-2    ] && mv -f ${PORN}/archive/urls.-2 ${PORN}/archive/urls.-3
[ -f ${PORN}/archive/domains.-1 ] && mv -f ${PORN}/archive/domains.-1 ${PORN}/archive/domains.-2
[ -f ${PORN}/archive/urls.-1    ] && mv -f ${PORN}/archive/urls.-1 ${PORN}/archive/urls.-2
[ -f ${PORN}/archive/domains.0  ] && mv -f ${PORN}/archive/domains.0 ${PORN}/archive/domains.-1
[ -f ${PORN}/archive/urls.0     ] && mv -f ${PORN}/archive/urls.0 ${PORN}/archive/urls.-1
cp ${PORN}/domains ${PORN}/archive/domains.0
cp ${PORN}/urls ${PORN}/archive/urls.0

[ -f ${ADULT}/archive/domains.-2 ] && mv -f ${ADULT}/archive/domains.-2 ${ADULT}/archive/domains.-3
[ -f ${ADULT}/archive/urls.-2    ] && mv -f ${ADULT}/archive/urls.-2 ${ADULT}/archive/urls.-3
[ -f ${ADULT}/archive/domains.-1 ] && mv -f ${ADULT}/archive/domains.-1 ${ADULT}/archive/domains.-2
[ -f ${ADULT}/archive/urls.-1    ] && mv -f ${ADULT}/archive/urls.-1 ${ADULT}/archive/urls.-2
[ -f ${ADULT}/archive/domains.0  ] && mv -f ${ADULT}/archive/domains.0 ${ADULT}/archive/domains.-1
[ -f ${ADULT}/archive/urls.0     ] && mv -f ${ADULT}/archive/urls.0 ${ADULT}/archive/urls.-1
cp ${ADULT}/domains ${ADULT}/archive/domains.0
cp ${ADULT}/urls ${ADULT}/archive/urls.0

# --------------------------------------------------------------
# Log item counts to porn statistics file
#

echo " " >> ${PORN}/stats/${UNIQUEDT}_stats
echo "University Toulouse blacklist files as downloaded" \
  >> ${PORN}/stats/${UNIQUEDT}_stats
echo "-------------------------------------------------" \
  >> ${PORN}/stats/${UNIQUEDT}_stats

wc --lines ${ADULT}/domains >> ${PORN}/stats/${UNIQUEDT}_stats
wc --lines ${ADULT}/urls >> ${PORN}/stats/${UNIQUEDT}_stats

# --------------------------------------------------------------
# Sort and de-dupe the _diff.local files
#

cat ${PORN}/domains_diff.local | sort | uniq > ${PORN}/domains.temp
cat ${PORN}/urls_diff.local | sort | uniq > ${PORN}/urls.temp
mv -f ${PORN}/domains.temp ${PORN}/domains_diff.local
mv -f ${PORN}/urls.temp ${PORN}/urls_diff.local

# --------------------------------------------------------------
# Log item counts to porn statistics file
#

echo " " >> ${PORN}/stats/${UNIQUEDT}_stats
echo "Local _diff.local files" >> ${PORN}/stats/${UNIQUEDT}_stats
echo "-----------------------" >> ${PORN}/stats/${UNIQUEDT}_stats

wc --lines ${PORN}/domains_diff.local >> ${PORN}/stats/${UNIQUEDT}_stats
wc --lines ${PORN}/urls_diff.local >> ${PORN}/stats/${UNIQUEDT}_stats

# --------------------------------------------------------------
# Create to_add &amp; to_delete files from the _diff.local files.
# The to_add files contain only the adds, and the to_delete files
# contain only the deletes.
# The _diff.local files are unchanged by this process.
#

grep -e '^+' ${PORN}/domains_diff.local > ${PORN}/domains.to_add
grep -e '^-' ${PORN}/domains_diff.local > ${PORN}/domains.to_delete
grep -e '^+' ${PORN}/urls_diff.local > ${PORN}/urls.to_add
grep -e '^-' ${PORN}/urls_diff.local > ${PORN}/urls.to_delete

# --------------------------------------------------------------
# Remove +/- from the to_add &amp; to_delete files
#

perl -pi -e "s#^\+##g" ${PORN}/urls.to_add
perl -pi -e "s#^\-##g" ${PORN}/urls.to_delete
perl -pi -e "s#^\+##g" ${PORN}/domains.to_add
perl -pi -e "s#^\-##g" ${PORN}/domains.to_delete

# --------------------------------------------------------------
# Log item counts to porn statistics file
#

echo " " >> ${PORN}/stats/${UNIQUEDT}_stats
echo "Local to_add and to_delete files" >> ${PORN}/stats/${UNIQUEDT}_stats
echo "--------------------------------" >> ${PORN}/stats/${UNIQUEDT}_stats

wc --lines ${PORN}/domains.to_add >> ${PORN}/stats/${UNIQUEDT}_stats
wc --lines ${PORN}/domains.to_delete >> ${PORN}/stats/${UNIQUEDT}_stats
wc --lines ${PORN}/urls.to_add >> ${PORN}/stats/${UNIQUEDT}_stats
wc --lines ${PORN}/urls.to_delete >> ${PORN}/stats/${UNIQUEDT}_stats

# --------------------------------------------------------------
# Combine the adult, blacklist and to_add files
# Remove garbage and blanks
# Remove duplicate entries
#

cat ${PORN}/archive/domains.0 ${ADULT}/archive/domains.0 ${PORN}/domains.to_add \
  > ${PORN}/domains.merged.1
cat ${PORN}/domains.merged.1 | tr -d '\000-\011' > ${PORN}/domains.merged.2
cat ${PORN}/domains.merged.2 | tr -d '\013-\037' > ${PORN}/domains.merged.3
cat ${PORN}/domains.merged.3 | tr -d '\177-\377' > ${PORN}/domains.merged.4
sort -u ${PORN}/domains.merged.4 > ${PORN}/domains.merged

cat ${PORN}/archive/urls.0 ${ADULT}/archive/urls.0 ${PORN}/urls.to_add \
  > ${PORN}/urls.merged.1
cat ${PORN}/urls.merged.1 | tr -d '\000-\011' > ${PORN}/urls.merged.2
cat ${PORN}/urls.merged.2 | tr -d '\013-\037' > ${PORN}/urls.merged.3
cat ${PORN}/urls.merged.3 | tr -d '\177-\377' > ${PORN}/urls.merged.4
sort -u ${PORN}/urls.merged.4 > ${PORN}/urls.merged

# --------------------------------------------------------------
# Log item counts to porn statistics file
#

echo " " >> ${PORN}/stats/${UNIQUEDT}_stats
echo "Combined adult, blacklist and to_add files, deduped" \
  >> ${PORN}/stats/${UNIQUEDT}_stats
echo "---------------------------------------------------" \
  >> ${PORN}/stats/${UNIQUEDT}_stats

wc --lines ${PORN}/domains.merged >> ${PORN}/stats/${UNIQUEDT}_stats
wc --lines ${PORN}/urls.merged >> ${PORN}/stats/${UNIQUEDT}_stats

# --------------------------------------------------------------
# Remove entries that match the content of the to_delete files
#

grep -v -x -F --file=${PORN}/domains.to_delete \
  ${PORN}/domains.merged > ${PORN}/domains.adjusted
grep -v -x -F --file=${PORN}/urls.to_delete \
  ${PORN}/urls.merged > ${PORN}/urls.adjusted

# --------------------------------------------------------------
# Log item counts to porn statistics file
#

echo " " >> ${PORN}/stats/${UNIQUEDT}_stats
echo "After removing the contents of the to_delete files" \
  >> ${PORN}/stats/${UNIQUEDT}_stats
echo "--------------------------------------------------" \
  >> ${PORN}/stats/${UNIQUEDT}_stats

wc --lines ${PORN}/domains.adjusted >> ${PORN}/stats/${UNIQUEDT}_stats
wc --lines ${PORN}/urls.adjusted >> ${PORN}/stats/${UNIQUEDT}_stats

# --------------------------------------------------------------
# Install new text files
#

mv -f ${PORN}/domains.adjusted ${PORN}/domains
mv -f ${PORN}/urls.adjusted ${PORN}/urls

# --------------------------------------------------------------
# Log item counts to porn statistics file
#

echo " " >> ${PORN}/stats/${UNIQUEDT}_stats
echo "Final production files" \
  >> ${PORN}/stats/${UNIQUEDT}_stats
echo "----------------------" \
  >> ${PORN}/stats/${UNIQUEDT}_stats

wc --lines ${PORN}/domains >> ${PORN}/stats/${UNIQUEDT}_stats
wc --lines ${PORN}/urls >> ${PORN}/stats/${UNIQUEDT}_stats

# --------------------------------------------------------------
# Create new databases in all categories
#

${SQUIDGUARD} -C all

# --------------------------------------------------------------
# Update databases from your domains.diff and urls.diff files
# NOTE: The -u[pdate] command only looks for domains.diff and
# urls.diff. It does NOT use the incremental files that are
# included in the blacklist file.
# e.g. domains.20011230.diff, urls.20011230.diff
#

${SQUIDGUARD} -u

# --------------------------------------------------------------
# Change ownership of blacklist files
#

chown -R proxy.proxy ${BLACKDIR}/blacklists

# --------------------------------------------------------------
# Bounce squid and squidguard
#

${SQUID} -k reconfigure

# --------------------------------------------------------------
# Delete work files
#

rm -f ${PORN}/domains.merged
rm -f ${PORN}/domains.merged.*
rm -f ${PORN}/domains.to_add
rm -f ${PORN}/domains.to_delete

rm -f ${PORN}/urls.merged
rm -f ${PORN}/urls.merged.*
rm -f ${PORN}/urls.to_add
rm -f ${PORN}/urls.to_delete

# --------------------------------------------------------------
# Display stats file
#

cat ${PORN}/stats/${UNIQUEDT}_stats

# --------------------------------------------------------------
# Wait for everything to finish, then exit
#

sleep 5s
exit 0
