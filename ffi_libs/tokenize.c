#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>

//========================================================================
// Necessary type and function declarations.
// Copied from llama.h

enum llama_model_kv_override_type {
    LLAMA_KV_OVERRIDE_TYPE_INT,
    LLAMA_KV_OVERRIDE_TYPE_FLOAT,
    LLAMA_KV_OVERRIDE_TYPE_BOOL,
    LLAMA_KV_OVERRIDE_TYPE_STR,
};

struct llama_model_kv_override {
    enum llama_model_kv_override_type tag;

    char key[128];

    union {
        int64_t val_i64;
        double  val_f64;
        bool    val_bool;
        char    val_str[128];
    };
};

enum llama_split_mode {
    LLAMA_SPLIT_MODE_NONE  = 0, // single GPU
    LLAMA_SPLIT_MODE_LAYER = 1, // split layers and KV across GPUs
    LLAMA_SPLIT_MODE_ROW   = 2, // split rows across GPUs
};

typedef bool (*llama_progress_callback)(float progress, void * user_data);

struct llama_model_params {
    int32_t n_gpu_layers; // number of layers to store in VRAM
    enum llama_split_mode split_mode; // how to split the model across multiple GPUs

    // main_gpu interpretation depends on split_mode:
    // LLAMA_SPLIT_MODE_NONE: the GPU that is used for the entire model
    // LLAMA_SPLIT_MODE_ROW: the GPU that is used for small tensors and intermediate results
    // LLAMA_SPLIT_MODE_LAYER: ignored
    int32_t main_gpu;

    // proportion of the model (layers or rows) to offload to each GPU, size: llama_max_devices()
    const float * tensor_split;

    // comma separated list of RPC servers to use for offloading
    const char * rpc_servers;

    // Called with a progress value between 0.0 and 1.0. Pass NULL to disable.
    // If the provided progress_callback returns true, model loading continues.
    // If it returns false, model loading is immediately aborted.
    llama_progress_callback progress_callback;

    // context pointer passed to the progress callback
    void * progress_callback_user_data;

    // override key-value pairs of the model meta data
    const struct llama_model_kv_override * kv_overrides;

    // Keep the booleans together to avoid misalignment during copy-by-value.
    bool vocab_only;    // only load the vocabulary, no weights
    bool use_mmap;      // use mmap if possible
    bool use_mlock;     // force system to keep model in RAM
    bool check_tensors; // validate model tensor data
};

struct llama_model;

struct llama_model_params          llama_model_default_params(void);

struct llama_model * llama_load_model_from_file(
                             const char * path_model,
              struct llama_model_params   params);

typedef int32_t llama_token;

int32_t llama_tokenize(
    const struct llama_model * model,
    const char * text,
        int32_t   text_len,
    llama_token * tokens,
        int32_t   n_tokens_max,
        bool   add_special,
        bool   parse_special);

void llama_free_model(struct llama_model * model);

//========================================================================

struct llama_model * model = NULL;

void doInit(const char *model_path) {
    struct llama_model_params model_params = llama_model_default_params();
    model_params.vocab_only = true;

    model = llama_load_model_from_file(model_path, model_params);

    if (model == NULL) {
        fprintf(stderr , "%s: error: unable to load model\n" , __func__);
        return;
    }
}

void doFini() {
    if (model != NULL) {
        llama_free_model(model);
    }
}

// find the number of tokens in the prompt
int64_t tokenize(const char *prompt) {
    int n_prompt = -llama_tokenize(model, prompt, strlen(prompt), NULL, 0, true, true);
    return n_prompt;
}

// int main() {
//     const char *model_path = "./token-model/Llama3.1-Chinese-Chat-vocab.gguf";
//     const char *prompt = "hello world again";
//     doInit(model_path);
//     printf("#token %d\n", tokenize(prompt));
//     doFini();
//     return 0;
// }