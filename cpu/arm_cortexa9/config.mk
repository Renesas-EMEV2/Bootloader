#
# (C) Copyright 2002
# Gary Jennejohn, DENX Software Engineering, <gj@denx.de>
#
# See file CREDITS for list of people who contributed to this
# project.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA 02111-1307 USA
#
PLATFORM_RELFLAGS += -fno-strict-aliasing -fno-common -ffixed-r8 \
		     -msoft-float

# Make ARMv5 to allow more compilers to work, even though its v7a.
PLATFORM_CPPFLAGS += -march=armv7-a
# =========================================================================
#
# Supply options according to compiler version
#
# =========================================================================
PLATFORM_CPPFLAGS += $(call cc-option,\
				-mabi=aapcs-linux -mno-thumb-interwork,\
				$(call cc-option,\
					-mapcs-32,\
					$(call cc-option,\
						-mabi=apcs-gnu,\
					)\
				) $(call cc-option,-mno-thumb-interwork,)\
			)
PLATFORM_RELFLAGS +=$(call cc-option,-mshort-load-bytes,\
		    $(call cc-option,-malignment-traps,))

# For EABI, make sure to provide raise()
ifneq (,$(findstring -mabi=aapcs-linux,$(PLATFORM_CPPFLAGS)))
# This file is parsed several times; make sure to add only once.
ifeq (,$(findstring lib_arm/eabi_compat.o,$(PLATFORM_LIBS)))
PLATFORM_LIBS += $(OBJTREE)/lib_arm/eabi_compat.o
endif
endif
