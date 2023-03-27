overview: contents/* LICENSE* metadata.*
	zip -FS -r -v overview.plasmoid contents LICENSE* metadata.*
clean:
	rm *.plasmoid