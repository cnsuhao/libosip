#*********************************************************************************************************
# libosip Makefile
# target -> libosip.a  
#           libosip.so
#*********************************************************************************************************

#*********************************************************************************************************
# include config.mk
#*********************************************************************************************************
CONFIG_MK_EXIST = $(shell if [ -f ../config.mk ]; then echo exist; else echo notexist; fi;)
ifeq ($(CONFIG_MK_EXIST), exist)
include ../config.mk
else
CONFIG_MK_EXIST = $(shell if [ -f config.mk ]; then echo exist; else echo notexist; fi;)
ifeq ($(CONFIG_MK_EXIST), exist)
include config.mk
else
CONFIG_MK_EXIST =
endif
endif

#*********************************************************************************************************
# check configure
#*********************************************************************************************************
check_defined = \
    $(foreach 1,$1,$(__check_defined))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $(value 2), ($(strip $2)))))

$(call check_defined, CONFIG_MK_EXIST, Please configure this project in RealCoder or \
create a config.mk file!)
$(call check_defined, SYLIXOS_BASE_PATH, SylixOS base project path)
$(call check_defined, TOOLCHAIN_PREFIX, the prefix name of toolchain)
$(call check_defined, DEBUG_LEVEL, debug level(debug or release))

#*********************************************************************************************************
# configure area you can set the following config to you own system
# FPUFLAGS (-mfloat-abi=softfp -mfpu=vfpv3 ...)
# CPUFLAGS (-mcpu=arm920t ...)
# NOTICE: libsylixos, BSP and other kernel modules projects CAN NOT use vfp!
#*********************************************************************************************************
FPUFLAGS = 
CPUFLAGS = -mcpu=arm920t $(FPUFLAGS)

#*********************************************************************************************************
# toolchain select
#*********************************************************************************************************
CC  = $(TOOLCHAIN_PREFIX)gcc
CXX = $(TOOLCHAIN_PREFIX)g++
AS  = $(TOOLCHAIN_PREFIX)gcc
AR  = $(TOOLCHAIN_PREFIX)ar
LD  = $(TOOLCHAIN_PREFIX)g++

#*********************************************************************************************************
# do not change the following code
# buildin internal application source
#*********************************************************************************************************
#*********************************************************************************************************
# src(s) file
#*********************************************************************************************************
SRCS = \
osip/src/osip2/fsm_misc.c \
osip/src/osip2/ict.c \
osip/src/osip2/ict_fsm.c \
osip/src/osip2/ist.c \
osip/src/osip2/ist_fsm.c \
osip/src/osip2/nict.c \
osip/src/osip2/nict_fsm.c \
osip/src/osip2/nist.c \
osip/src/osip2/nist_fsm.c \
osip/src/osip2/osip.c \
osip/src/osip2/osip_dialog.c \
osip/src/osip2/osip_event.c \
osip/src/osip2/osip_time.c \
osip/src/osip2/osip_transaction.c \
osip/src/osip2/port_condv.c \
osip/src/osip2/port_fifo.c \
osip/src/osip2/port_sema.c \
osip/src/osip2/port_thread.c \
osip/src/osipparser2/osip_accept.c \
osip/src/osipparser2/osip_accept_encoding.c \
osip/src/osipparser2/osip_accept_language.c \
osip/src/osipparser2/osip_alert_info.c \
osip/src/osipparser2/osip_allow.c \
osip/src/osipparser2/osip_authentication_info.c \
osip/src/osipparser2/osip_authorization.c \
osip/src/osipparser2/osip_body.c \
osip/src/osipparser2/osip_call_id.c \
osip/src/osipparser2/osip_call_info.c \
osip/src/osipparser2/osip_contact.c \
osip/src/osipparser2/osip_content_disposition.c \
osip/src/osipparser2/osip_content_encoding.c \
osip/src/osipparser2/osip_content_length.c \
osip/src/osipparser2/osip_content_type.c \
osip/src/osipparser2/osip_cseq.c \
osip/src/osipparser2/osip_error_info.c \
osip/src/osipparser2/osip_from.c \
osip/src/osipparser2/osip_header.c \
osip/src/osipparser2/osip_list.c \
osip/src/osipparser2/osip_md5c.c \
osip/src/osipparser2/osip_message.c \
osip/src/osipparser2/osip_message_parse.c \
osip/src/osipparser2/osip_message_to_str.c \
osip/src/osipparser2/osip_mime_version.c \
osip/src/osipparser2/osip_parser_cfg.c \
osip/src/osipparser2/osip_port.c \
osip/src/osipparser2/osip_proxy_authenticate.c \
osip/src/osipparser2/osip_proxy_authentication_info.c \
osip/src/osipparser2/osip_proxy_authorization.c \
osip/src/osipparser2/osip_record_route.c \
osip/src/osipparser2/osip_route.c \
osip/src/osipparser2/osip_to.c \
osip/src/osipparser2/osip_uri.c \
osip/src/osipparser2/osip_via.c \
osip/src/osipparser2/osip_www_authenticate.c \
osip/src/osipparser2/sdp_accessor.c \
osip/src/osipparser2/sdp_message.c

#*********************************************************************************************************
# build path
#*********************************************************************************************************
ifeq ($(DEBUG_LEVEL), debug)
OUTDIR = Debug
else
OUTDIR = Release
endif

OUTPATH = ./$(OUTDIR)
OBJPATH = $(OUTPATH)/obj
DEPPATH = $(OUTPATH)/dep

#*********************************************************************************************************
#  target
#*********************************************************************************************************
LIB = $(OUTPATH)/libosip.a
DLL = $(OUTPATH)/libosip.so

#*********************************************************************************************************
# objects
#*********************************************************************************************************
OBJS = $(addprefix $(OBJPATH)/, $(addsuffix .o, $(basename $(SRCS))))
DEPS = $(addprefix $(DEPPATH)/, $(addsuffix .d, $(basename $(SRCS))))

#*********************************************************************************************************
# include path
#*********************************************************************************************************
INCDIR  = -I"$(SYLIXOS_BASE_PATH)/libsylixos/SylixOS"
INCDIR += -I"$(SYLIXOS_BASE_PATH)/libsylixos/SylixOS/include"
INCDIR += -I"$(SYLIXOS_BASE_PATH)/libsylixos/SylixOS/include/inet"
INCDIR += -I"./osip/include"

#*********************************************************************************************************
# compiler preprocess
#*********************************************************************************************************
DSYMBOL  = -DSYLIXOS
DSYMBOL += -DSYLIXOS_LIB 
DSYMBOL += -DHAVE_PTHREAD -DHAVE_STRUCT_TIMEVAL -DHAVE_SEMAPHORE_H

#*********************************************************************************************************
# depend dynamic library
#*********************************************************************************************************
DEPEND_DLL = 

#*********************************************************************************************************
# depend dynamic library search path
#*********************************************************************************************************
DEPEND_DLL_PATH = 

#*********************************************************************************************************
# compiler optimize
#*********************************************************************************************************
ifeq ($(DEBUG_LEVEL), debug)
OPTIMIZE = -O0 -g3 -gdwarf-2
else
OPTIMIZE = -O2 -g1 -gdwarf-2											# Do NOT use -O3 and -Os
endif										    						# -Os is not align for function
																		# loop and jump.
#*********************************************************************************************************
# depends and compiler parameter (cplusplus in kernel MUST NOT use exceptions and rtti)
#*********************************************************************************************************
DEPENDFLAG  = -MM
CXX_EXCEPT  = -fno-exceptions -fno-rtti
COMMONFLAGS = $(CPUFLAGS) $(OPTIMIZE) -Wall -fmessage-length=0 -fsigned-char -fno-short-enums
ASFLAGS     = -x assembler-with-cpp $(DSYMBOL) $(INCDIR) $(COMMONFLAGS) -c
CFLAGS      = $(DSYMBOL) $(INCDIR) $(COMMONFLAGS) -fPIC -c
CXXFLAGS    = $(DSYMBOL) $(INCDIR) $(CXX_EXCEPT) $(COMMONFLAGS) -fPIC -c
ARFLAGS     = -r

#*********************************************************************************************************
# define some useful variable
#*********************************************************************************************************
DEPEND          = $(CC)  $(DEPENDFLAG) $(CFLAGS)
DEPEND.d        = $(subst -g ,,$(DEPEND))
COMPILE.S       = $(AS)  $(ASFLAGS)
COMPILE_VFP.S   = $(AS)  $(ASFLAGS)
COMPILE.c       = $(CC)  $(CFLAGS)
COMPILE.cxx     = $(CXX) $(CXXFLAGS)

#*********************************************************************************************************
# target
#*********************************************************************************************************
all: $(LIB) $(DLL)
		@echo create "$(LIB) $(DLL)" success.

#*********************************************************************************************************
# include depends
#*********************************************************************************************************
ifneq ($(MAKECMDGOALS), clean)
ifneq ($(MAKECMDGOALS), clean_project)
sinclude $(DEPS)
endif
endif

#*********************************************************************************************************
# create depends files
#*********************************************************************************************************
$(DEPPATH)/%.d: %.c
		@echo creating $@
		@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
		@rm -f $@; \
		echo -n '$@ $(addprefix $(OBJPATH)/, $(dir $<))' > $@; \
		$(DEPEND.d) $< >> $@ || rm -f $@; exit;

$(DEPPATH)/%.d: %.cpp
		@echo creating $@
		@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
		@rm -f $@; \
		echo -n '$@ $(addprefix $(OBJPATH)/, $(dir $<))' > $@; \
		$(DEPEND.d) $< >> $@ || rm -f $@; exit;

#*********************************************************************************************************
# compile source files
#*********************************************************************************************************
$(OBJPATH)/%.o: %.S
		@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
		$(COMPILE.S) $< -o $@

$(OBJPATH)/%.o: %.c
		@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
		$(COMPILE.c) $< -o $@

$(OBJPATH)/%.o: %.cpp
		@if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
		$(COMPILE.cxx) $< -o $@

#*********************************************************************************************************
# link libosip.a object files
#*********************************************************************************************************
$(LIB): $(OBJS)
		$(AR) $(ARFLAGS) $(LIB) $(OBJS)

#*********************************************************************************************************
# link libosip.so object files
#*********************************************************************************************************
$(DLL): $(OBJS)
		$(LD) $(CPUFLAGS) -nostdlib -fPIC -shared -o $(DLL) $(OBJS) \
		$(DEPEND_DLL_PATH) $(DEPEND_DLL) -lm -lgcc

#*********************************************************************************************************
# clean
#*********************************************************************************************************
.PHONY: clean
.PHONY: clean_project

#*********************************************************************************************************
# clean objects
#*********************************************************************************************************
clean:
		-rm -rf $(LIB)
		-rm -rf $(DLL)
		-rm -rf $(OBJPATH)
		-rm -rf $(DEPPATH)

#*********************************************************************************************************
# clean project
#*********************************************************************************************************
clean_project:
		-rm -rf $(OUTPATH)

#*********************************************************************************************************
# END
#*********************************************************************************************************
