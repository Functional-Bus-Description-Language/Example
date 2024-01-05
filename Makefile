.PHONY: fbdl
fbdl:
	fsva ::tb_fbdl tb_cosim

fbdl-synth:
	fusesoc --cores-root . run --no-export --setup --build --target default ::tb_fbdl

.PHONY: agwb
agwb:
	fsva ::tb_agwb tb_cosim

agwb-synth:
	fusesoc --cores-root . run --no-export --setup --build --target default ::tb_agwb
