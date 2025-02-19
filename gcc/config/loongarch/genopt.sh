#!/bin/sh
# Generate loongarch-tables.opt from the list of CPUs in loongarch-cpus.def.
# Copyright (C) 2011-2021 Free Software Foundation, Inc.
#
# This file is part of GCC.
#
# GCC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# GCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with GCC; see the file COPYING3.  If not see
# <http://www.gnu.org/licenses/>.

cat <<EOF
; -*- buffer-read-only: t -*-
; Generated automatically by genopt.sh from loongarch-cpus.def.

; Copyright (C) 2020-2021 Free Software Foundation, Inc.
;
; This file is part of GCC.
;
; GCC is free software; you can redistribute it and/or modify it under
; the terms of the GNU General Public License as published by the Free
; Software Foundation; either version 3, or (at your option) any later
; version.
;
; GCC is distributed in the hope that it will be useful, but WITHOUT ANY
; WARRANTY; without even the implied warranty of MERCHANTABILITY or
; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
; for more details.
;
; You should have received a copy of the GNU General Public License
; along with GCC; see the file COPYING3.  If not see
; <http://www.gnu.org/licenses/>.

Enum
Name(loongarch_arch_opt_value) Type(int)
Known LoongArch CPUs (for use with the -march= and -mtune= options):

EnumValue
Enum(loongarch_arch_opt_value) String(native) Value(LARCH_ARCH_OPTION_NATIVE) DriverOnly

EOF

awk -F'[(, 	]+' '
BEGIN {
    value = 0
}

# Write an entry for a single string accepted as a -march= argument.

function write_one_arch_value(name, value, flags)
{
    print "EnumValue"
    print "Enum(loongarch_arch_opt_value) String(" name ") Value(" value ")" flags
    print ""
}

# The logic for matching CPU name variants should be the same as in GAS.

# Write an entry for a single string accepted as a -march= argument,
# plus any variant with a final "000" replaced by "k".

function write_arch_value_maybe_k(name, value, flags)
{
    write_one_arch_value(name, value, flags)
}

# Write all the entries for a -march= argument.  In addition to
# replacement of a final "000" with "k", an argument starting with
# "vr", "rm" or "r" followed by a number, or just a plain number,
# matches a plain number or "r" followed by a plain number.

function write_all_arch_values(name, value)
{
    write_arch_value_maybe_k(name, value, " Canonical")
    cname = name
    if (cname ~ "^vr") {
	sub("^vr", "", cname)
    } else if (cname ~ "^rm") {
	sub("^rm", "", cname)
    } else if (cname ~ "^r") {
	sub("^r", "", cname)
    }
    if (cname ~ "^[0-9]") {
	if (cname != name)
	    write_arch_value_maybe_k(cname, value, "")
	rname = "r" cname
	if (rname != name)
	    write_arch_value_maybe_k(rname, value, "")
    }
}

/^LARCH_CPU/ {
    name = $2
    gsub("\"", "", name)
    write_all_arch_values(name, value)
    value++
}' $1/loongarch-cpus.def
