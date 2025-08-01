version 1.0

workflow hellowld
{
	input{
	String hello = "Path to My Reads"
}	

	call helloworld {
	input:
	hello_in = hello


			}	
	output {

	File out_worflow = helloworld.hello_out


		}
}
task helloworld
{

	input {

	String hello_in
		}
command {
	echo ~{hello_in} > hello.txt

	}
output {
	File hello_out = "hello.txt"
	}

}
