#!/usr/bin/env bash

MYSQL='mysql5 -u root people'
#MYSQL='cat' #debug

echo "============="
echo "row for id=55"
echo "============="
echo ""
${MYSQL} <<EOF
explain  extended
 select  p.name, a.city, a.state
   from  people p
   join  residences on p.id = person_id
   join  addresses a on a.id = address_id
  where  p.id = 55
EOF

echo ""
echo "============="
echo "row for 'O%'"
echo "============="
echo ""

${MYSQL}<<EOF
explain  extended
 select  p.name, a.city, a.state
   from  people p
   join  residences on p.id = person_id
   join  addresses a on a.id = address_id
   where p.name like 'O%'
EOF
echo ""
echo "============="

echo <<EOF
explain  extended
 select  p.name, a.city, a.state
   from  people p
   join  residences on p.id = person_id
   join  addresses a on a.id = address_id
  where  p.id = 55;

explain  extended
 select  p.name, a.city, a.state
   from  people p
   join  residences on p.id = person_id
   join  addresses a on a.id = address_id
   where p.name like 'O%';

EOF

EOF