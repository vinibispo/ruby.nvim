.PHONY: test prepare

test:
	@nvim \
		--headless \
		--noplugin \
		-u tests/minimal_vim.vim \
		-c "PlenaryBustedDirectory tests/ruby_nvim { minimal_init = 'tests/minimal_vim.vim' }"
