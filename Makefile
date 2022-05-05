all: scan

scan: scanner.cpp
	g++ scanner.cpp -o scan

scanner.cpp: scanner.l
	flex -o scanner.cpp scanner.l

parse: parser.cpp scanner.cpp
	g++ parser.cpp scanner.cpp -o parse

parser.cpp parser.hpp: parser.y
	bison -d -o parser.cpp parser.y

clean:
	rm -f scan scanner.cpp parse parser.cpp parser.hpp

new:
	rm -f scan scanner.cpp parse parser.cpp parser.hpp
	bison -d -o parser.cpp -v parser.y
	flex -o scanner.cpp scanner.l
	g++ parser.cpp scanner.cpp -o parse
test:
	rm -f scan scanner.cpp parse parser.cpp parser.hpp output.txt
	bison -d -o parser.cpp -v parser.y
	flex -o scanner.cpp scanner.l
	g++ parser.cpp scanner.cpp -o parse
	./parse < ./testing_code/test.py
