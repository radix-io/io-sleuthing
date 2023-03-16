#include <stdlib.h>
#include <unistd.h>
#include <mpi.h>
#include <pnetcdf.h>
#include <stdio.h>

#define NVARS 5
#define DIM0  (230 * 1000)

static void handle_error(int status, int lineno)
{
    fprintf(stderr, "Error at line %d: %s\n", lineno, ncmpi_strerror(status));
    MPI_Abort(MPI_COMM_WORLD, 1);
}

int main(int argc, char **argv) {

    int ret, ncfile, nprocs, rank, dimid[2], ndims=2;
    int varid[NVARS];
    MPI_Offset start[2], count[2];
    char buf[13] = "Hello World\n";
    int* write_buf;

    int requests[NVARS], statuses[NVARS];

    MPI_Init(&argc, &argv);

    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);

    if (argc != 2) {
        if (rank == 0) printf("Usage: %s filename\n", argv[0]);
        MPI_Finalize();
        exit(-1);
    }

    ret = ncmpi_create(MPI_COMM_WORLD, argv[1],
                       NC_CLOBBER|NC_64BIT_OFFSET, MPI_INFO_NULL, &ncfile);
    if (ret != NC_NOERR) handle_error(ret, __LINE__);

    ret = ncmpi_def_dim(ncfile, "d1", DIM0, &dimid[0]);
    if (ret != NC_NOERR) handle_error(ret, __LINE__);
    ret = ncmpi_def_dim(ncfile, "rank", nprocs, &dimid[1]);
    if (ret != NC_NOERR) handle_error(ret, __LINE__);

    for (int i=0; i< NVARS; i++) {
	char varname[16];
	snprintf(varname, 16, "v%d", i);
	ret = ncmpi_def_var(ncfile, varname, NC_INT, ndims, dimid, &(varid[i]));
	if (ret != NC_NOERR) handle_error(ret, __LINE__);
    }

    ret = ncmpi_put_att_text(ncfile, NC_GLOBAL, "string", 13, buf);
    if (ret != NC_NOERR) handle_error(ret, __LINE__);

    /* all processors defined the dimensions, attributes, and variables,
     * but here in ncmpi_enddef is the one place where metadata I/O
     * happens.  Behind the scenes, rank 0 takes the information and writes
     * the netcdf header.  All processes communicate to ensure they have
     * the same (cached) view of the dataset */

    ret = ncmpi_enddef(ncfile);
    if (ret != NC_NOERR) handle_error(ret, __LINE__);

    /* generating some synthetic data */
    write_buf = malloc(DIM0*sizeof(int) );
    for (int i=0; i< DIM0; i++) {
	write_buf[i] = (10*i)+rank;
    }

    start[0]=0, start[1] = rank;
    count[0]=DIM0, count[1] = 1;

    /* we used a basic MPI_INT type to this flexible mode call, but could
     * have used any derived MPI datatype that describes application data
     * structures */

    /* compare two approaches:
     * - one collective at a time
     * - using non-blocing operations to combine them all */
    srand(10+rank);
    for (int j=0; j< NVARS; j++)  {
	/* mimic doing some computation
	 * additionally, pretend the computation is unevenly distributed across processes */
	usleep(rand()%5000000);

#ifdef PNETCDF_NON_BLOCKING
	/* the non-blockig operations don't actually do any i/o, so we can
	 * issue them non-collectively */
	ret = ncmpi_iput_vara(ncfile, varid[j], start, count,
		write_buf, count[0], MPI_INT,
		&requests[j]);
#else
	ret = ncmpi_put_vara_all(ncfile, varid[j], start, count,
		write_buf, count[0], MPI_INT);
	if (ret != NC_NOERR) handle_error(ret, __LINE__);
#endif
    }

#ifdef PNETCDF_NON_BLOCKING
    /* in the non-blocking case, this collective wait routine is where all the
     * work happens: there is no background i/o thread  */
    ret = ncmpi_wait_all(ncfile, NVARS, requests, statuses);
    if (ret != NC_NOERR) handle_error(ret, __LINE__);

    /* check status of each nonblocking call */
    for (int j=0; j< NVARS; j++)
	if (statuses[j] != NC_NOERR) handle_error(statuses[j], __LINE__);
#endif

    ret = ncmpi_close(ncfile);
    if (ret != NC_NOERR) handle_error(ret, __LINE__);

    MPI_Finalize();
    free(write_buf);

    return 0;
}
