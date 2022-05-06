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
	./parse < ./testing_code/p1.py > output1.cpp
	./parse < ./testing_code/p2.py > output2.cpp
	./parse < ./testing_code/p3.py > output3.cpp
	./parse < ./testing_code/p4.py > output4.cpp
	g++ output1.cpp -o run1
	g++ output2.cpp -o run2
	g++ output3.cpp -o run3
	g++ output4.cpp -o run4