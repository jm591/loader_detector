#include "ruby.h"
#include "netpbm/pam.h"


static VALUE compare_pamfiles(VALUE self){

    pm_init("404", 0);

    struct pam pam1;
    struct pam pam2;

    FILE *input_file1 = fopen("/tmp/image1.pam", "r");
    FILE *input_file2 = fopen("/tmp/image2.pam", "r");
    if(input_file1 == NULL || input_file2 == NULL){
        rename("/tmp/image1.pam", "/tmp/image2.pam");
        return INT2NUM(-2);
    }

    pnm_readpaminit(input_file1, &pam1, PAM_STRUCT_SIZE(tuple_type));
    pnm_readpaminit(input_file2, &pam2, PAM_STRUCT_SIZE(tuple_type));


    if(pam1.height != pam2.height || pam1.width != pam2.width || pam1.depth != pam2.depth){
        rename("/tmp/image1.pam", "/tmp/image2.pam");
        return INT2NUM(-1);
    }
    if(pam1.height == 0 || pam1.width == 0 || pam2.height == 0 || pam2.width == 0 || pam1.depth == 0 || pam2.depth == 0){
        rename("/tmp/image1.pam", "/tmp/image2.pam");
        return INT2NUM(-3);
    }

    int count = 0;
    int row;
    for (row = 0; row < pam1.height; ++row) {
        int column;
        tuple *tuple_row1 = pnm_allocpamrow(&pam1);
        tuple *tuple_row2 = pnm_allocpamrow(&pam2);
        pnm_readpamrow(&pam1, tuple_row1);
        pnm_readpamrow(&pam2, tuple_row2);
        for (column = 0; column < pam1.width; ++column) {
            for (unsigned int depth = 0; depth < pam1.depth; ++depth){
                if(tuple_row1[column][depth] != tuple_row2[column][depth]){
                    ++count;
                } 
            }
        }
        pnm_freepamrow(tuple_row1);
        pnm_freepamrow(tuple_row2);
    }

    fclose(input_file1);
    fclose(input_file2);

    rename("/tmp/image1.pam", "/tmp/image2.pam");
    return INT2NUM(count);
}


void Init_imageComp(void) {
    VALUE ImageCompare = rb_define_module("ImageCompare");
    VALUE Helpers = rb_define_class_under(ImageCompare, "Helpers", rb_cObject);
    rb_define_singleton_method(Helpers, "compare_pamfiles", compare_pamfiles, 0);
}