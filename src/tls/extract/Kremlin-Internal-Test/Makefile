# Note: please backport any changes here to ../Kremlin-Library/Makefile

UNAME		= $(shell uname)
MARCH		?= x86_64

MITLS_HOME 	= ../../../..
MLCRYPTO_HOME	?= ../../../../../MLCrypto

ifeq ($(OS),Windows_NT)
  ifeq ($(shell uname -o),Cygwin)
    MLCRYPTO_HOME := $(shell cygpath -u ${MLCRYPTO_HOME})
  endif
  PATH := $(MITLS_HOME)/src/pki:$(PATH)
  SO = dll
  CC ?= x86_64-w64-mingw32-gcc
  export PATH
else ifeq ($(UNAME),Darwin)
  VARIANT = -Darwin
  DYLD_LIBRARY_PATH := $(MITLS_HOME)/src/pki:$(DYLD_LIBRARY_PATH)
  SO = so
  export DYLD_LIBRARY_PATH
else ifeq ($(UNAME),Linux)
  VARIANT = -Linux
  LD_LIBRARY_PATH := $(MITLS_HOME)/src/pki:$(LD_LIBRARY_PATH)
  LDOPTS := -lpthread $(LDOPTS)
  SO = so
  export LD_LIBRARY_PATH
endif

ifeq (,$(wildcard $(MITLS_HOME)/src/pki/libmipki.$(SO)))
  $(error MITLS_HOME is $(MITLS_HOME) and I cannot find $(MITLS_HOME)/src/pki/libmipki.$(SO) -- please run make in $(MITLS_HOME)/src/pki)
endif

ifndef NO_OPENSSL
ifeq ($(OS),Windows_NT)
  PATH := $(MLCRYPTO_HOME)/openssl:$(PATH)
else ifeq ($(UNAME),Darwin)
  DYLD_LIBRARY_PATH := $(MLCRYPTO_HOME)/openssl:$(DYLD_LIBRARY_PATH)
else
  LD_LIBRARY_PATH := $(MLCRYPTO_HOME)/openssl:$(LD_LIBRARY_PATH)
endif
endif

INCLUDE_DIRS 	= secure kremlib include stub vale curve pki ffi .

# ls *.c */*.c | sed 's/\.c//g' >> Makefile
# then: remove Crypto_AEAD_Main because of the hacl_provider hack
# then: remove Crypto_Symmetric_Bytes
FILES 		= Cert C_Loops_Spec_Loops CommonDH CoreCrypto \
  Crypto_AEAD_Crypto_Symmetric_Buffer_Utils_Crypto_Plain Crypto_Indexing \
  CryptoTypes curve/Curve25519 DHGroup ECGroup Extensions Flag Flags FStar \
  HaclProvider Hashing_Spec kremlib/kremdate kremlib/kremstr kremlinit \
  LowCProvider Nonce Parse PMS Prims PSK RSAKey \
  secure/Crypto_HKDF_Crypto_HMAC \
  Specializations_Providers_AEAD stub/mipki_wrapper stub/core_crypto stub/hacl_aead \
  stub/hacl_provider Test_Main TLSConstants TLS_Curve25519 TLSError TLSInfo \
  TLSInfoFlags vale/sha256_main_i vale/vale_aes_glue vale/Vale_Hash_SHA2_256

CFLAGS := $(addprefix -I,$(INCLUDE_DIRS)) $(CFLAGS) -Wall -Werror \
  -Wno-unused-variable -Wno-parentheses -Wno-unknown-warning-option \
  -Wno-unused-but-set-variable -Wno-infinite-recursion -g -fwrapv -fstack-check \
  -D_BSD_SOURCE -D_DEFAULT_SOURCE -D__USE_MINGW_ANSI_STDIO \
  -Wno-missing-braces

ifndef NO_OPENSSL
CFLAGS += -I$(MLCRYPTO_HOME)/openssl/include
LDOPTS += -L$(MLCRYPTO_HOME)/openssl -lcrypto -lssl
else
CFLAGS += -DNO_OPENSSL
endif

all: test.exe

-include .depend

.depend:
	$(CC) $(CFLAGS) -MM $(addsuffix .c,$(FILES)) > $@

test.exe: $(addsuffix .o,$(FILES)) vale/sha256-$(MARCH)$(VARIANT).o vale/aes-$(MARCH)$(VARIANT).o
	$(CC) $^ -o $@ -lmipki $(LDOPTS) -L$(MITLS_HOME)/src/pki

test: all
	./test.exe