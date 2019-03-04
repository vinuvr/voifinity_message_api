PROJECT = voifinity_message_api
PROJECT_DESCRIPTION = Voifinity_Message_Api Plugin
PROJECT_VERSION = 1.0

BUILD_DEPS = emqx
dep_emqx = git https://github.com/emqx/emqx
dep_cuttlefish = git https://github.com/emqx/cuttlefish
dep_uuid= git https://github.com/okeuday/uuid
ERLC_OPTS += +debug_info

NO_AUTOPATCH = cuttlefish

COVER = true

include erlang.mk

app:: rebar.config

app.config::
	./deps/cuttlefish/cuttlefish -l info -e etc/ -c etc/voifinity_message_api.conf -i priv/voifinity_message_api.schema -d data
