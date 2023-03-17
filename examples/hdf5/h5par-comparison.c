/* HDF5 Dataset example, collective I/O */

/* System header files */
#include <assert.h>

/* HDF5 header file */
#include "hdf5.h"

/* Predefined names and sizes */
#define DATASETNAME "Dataset 1"
#define RANK    2
#define DIM0    (230 * 1000)

/* Global variables: kind of big so we don't declare them on the stack */
double write_buf[DIM0];
double read_buf[DIM0];

int main(int argc, char *argv[])
{
    hid_t file_id;              /* File ID */
    hid_t fapl_id;		/* File access property list */
    hid_t dset_id;		/* Dataset ID */
    hid_t file_space_id;	/* File dataspace ID */
    hid_t mem_space_id;		/* Memory dataspace ID */
    hsize_t file_dims[RANK];   	/* Dataset dimemsion sizes */
    hsize_t mem_dims[1];   	/* Memory buffer dimemsion sizes */
    hsize_t file_start[RANK];	/* File dataset selection start coordinates (for hyperslab setting) */
    hsize_t file_count[RANK];	/* File dataset selection count coordinates (for hyperslab setting) */
    hsize_t mem_start[1];	/* Memory buffer selection start coordinates (for hyperslab setting) */
    hsize_t mem_count[1];	/* Memory buffer selection count coordinates (for hyperslab setting) */
    hid_t dxpl_id;		/* Dataset transfer property list */
    int mpi_size, mpi_rank;	/* MPI variables */
    herr_t ret;         	/* Generic return value */

    /* Initialize MPI */
    MPI_Init(&argc, &argv);

    /* Gather information about MPI comm size and my rank */
    MPI_Comm_size(MPI_COMM_WORLD, &mpi_size);
    MPI_Comm_rank(MPI_COMM_WORLD, &mpi_rank);

    /* Iniialize buffer of dataset to write */
    /* (in a real application, this would be your science data) */
    for (int i=0; i<DIM0; i++)
        write_buf[i] = (100.0+i)*mpi_rank;

    /* Create an HDF5 file access property list */
    fapl_id = H5Pcreate (H5P_FILE_ACCESS);
    assert(fapl_id > 0);

#ifdef USE_COLL_MD
    H5Pset_all_coll_metadata_ops(fapl_id, 1);
    H5Pset_coll_metadata_write(fapl_id, 1);
#endif

    /* Set file access property list to use the MPI-IO file driver */
    ret = H5Pset_fapl_mpio(fapl_id, MPI_COMM_WORLD, MPI_INFO_NULL);
    assert(ret >= 0);

    /* Create the file collectively */
    file_id = H5Fcreate(argv[1], H5F_ACC_TRUNC, H5P_DEFAULT, fapl_id);
    assert(file_id > 0);

    /* Release file access property list */
    ret = H5Pclose(fapl_id);
    assert(ret >= 0);


    /* Define a file dataspace the dimensions of the dataset */
    file_dims[0] = DIM0;
    file_dims[1] = mpi_size;
    file_space_id = H5Screate_simple(RANK, file_dims, NULL);
    assert(file_space_id > 0);

    /* Create the dataset collectively */
    dset_id = H5Dcreate2(file_id, DATASETNAME, H5T_NATIVE_DOUBLE,
        file_space_id, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
    assert(dset_id > 0);


    /* Create memory dataspace for write buffer */
    mem_dims[0] = DIM0;
    mem_space_id = H5Screate_simple(1, mem_dims, NULL);
    assert(mem_space_id > 0);


    /* Select column of elements in the file dataset */
    file_start[0] = 0;
    file_start[1] = mpi_rank;
    file_count[0] = DIM0;
    file_count[1] = 1;
    ret = H5Sselect_hyperslab(file_space_id, H5S_SELECT_SET, file_start, NULL, file_count, NULL);
    assert(ret >= 0);

    /* Select all elements in the memory buffer */
    mem_start[0] = 0;
    mem_count[0] = DIM0;
    ret = H5Sselect_hyperslab(mem_space_id, H5S_SELECT_SET, mem_start, NULL, mem_count, NULL);
    assert(ret >= 0);


#ifdef USE_COLL_DATA
    /* Set up the collective transfer properties list */
    dxpl_id = H5Pcreate(H5P_DATASET_XFER);
    assert(dxpl_id > 0);
    ret = H5Pset_dxpl_mpio(dxpl_id, H5FD_MPIO_COLLECTIVE);
    assert(ret >= 0);
#else
    dxpl_id = H5P_DEFAULT;
#endif

    /* Write data collectively */
    ret = H5Dwrite(dset_id, H5T_NATIVE_DOUBLE, mem_space_id, file_space_id,
	    dxpl_id, write_buf);
    assert(ret >= 0);

    /* Release dataset transfer property list */
    ret = H5Pclose(dxpl_id);
    assert(ret >= 0);


    /* Close memory dataspace */
    ret = H5Sclose(mem_space_id);
    assert(ret >= 0);

    /* Close file dataspace */
    ret = H5Sclose(file_space_id);
    assert(ret >= 0);

    /* Close dataset collectively */
    ret = H5Dclose(dset_id);
    assert(ret >= 0);

    /* Close the file collectively */
    ret = H5Fclose(file_id);
    assert(ret >= 0);

    /* now read it back */
    fapl_id = H5Pcreate(H5P_FILE_ACCESS);
    assert(fapl_id > 0);

    ret = H5Pset_fapl_mpio(fapl_id, MPI_COMM_WORLD, MPI_INFO_NULL);
    assert(ret >= 0);

#ifdef USE_COLL_MD
    H5Pset_all_coll_metadata_ops(fapl_id, 1);
    H5Pset_coll_metadata_write(fapl_id, 1);
#endif

    file_id = H5Fopen(argv[1], H5F_ACC_RDONLY, fapl_id);
    assert (file_id > 0);

    ret = H5Pclose(fapl_id);
    assert(ret >= 0);

    dset_id = H5Dopen2(file_id, DATASETNAME, H5P_DEFAULT);
    assert(dset_id > 0);

    file_space_id = H5Dget_space(dset_id);
    file_start[0] = 0;
    file_start[1] = mpi_rank;
    file_count[0] = DIM0;
    file_count[1] = 1;
    ret = H5Sselect_hyperslab(file_space_id, H5S_SELECT_SET, file_start, NULL, file_count, NULL);
    assert(ret >= 0);

    mem_dims[0] = DIM0;
    mem_space_id = H5Screate_simple(1, mem_dims, NULL);
    assert(mem_space_id > 0);

#ifdef USE_COLL_DATA
    dxpl_id = H5Pcreate(H5P_DATASET_XFER);
    assert(dxpl_id > 0);
    ret = H5Pset_dxpl_mpio(dxpl_id, H5FD_MPIO_COLLECTIVE);
    assert(ret >= 0);
#else
    dxpl_id = H5P_DEFAULT;
#endif

    ret = H5Dread(dset_id, H5T_NATIVE_DOUBLE, mem_space_id, file_space_id,
            dxpl_id, read_buf);

    /* MPI_Finalize must be called AFTER any HDF5 call which may use MPI calls */
    MPI_Finalize();

    return(0);
}

