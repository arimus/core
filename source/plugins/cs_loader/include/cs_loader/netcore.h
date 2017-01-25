#pragma once
#ifndef _NETCORE_H_
#define _NETCORE_H_
#include <cs_loader/defs.h>
#include <stdlib.h>
class netcore
{
protected:

	reflect_function functions[100];
	int functions_count;
public:

	load_function_w * core_load_w;
	load_function_c * core_load_c;
	execute_function_w * execute_w;
	execute_function_c * execute_c;
	execute_function_with_params_w * execute_with_params_w;
	execute_function_with_params_c * execute_with_params_c;
	get_loaded_functions * core_get_functions;
	destroy_execution_result * core_destroy_execution_result;

	const CHARSTRING *loader_dll = W("CSLoader.dll");
	const CHARSTRING *class_name = W("CSLoader.Loader");
	const CHARSTRING *assembly_name = W("CSLoader");
	const CHARSTRING *delegate_load_w = W("LoadW");
	const CHARSTRING *delegate_load_c = W("LoadC");
	const CHARSTRING *delegate_execute_w = W("ExecuteW");
	const CHARSTRING *delegate_execute_c = W("ExecuteC");
	const CHARSTRING *delegate_execute_with_params_w = W("ExecuteWithParamsW");
	const CHARSTRING *delegate_execute_with_params_c = W("ExecuteWithParamsC");
	const CHARSTRING *delegate_get_functions = W("GetFunctions");
	const CHARSTRING *delegate_destroy_execution_result = W("DestroyExecutionResult");

	explicit netcore();
	virtual ~netcore();

	virtual bool start() = 0;
	virtual void stop() = 0;

	bool load_source(wchar_t * source);
	bool load_source(char * source);

	execution_result* execute(char * function);
	execution_result* execute(wchar_t * function);

	execution_result* execute_with_params(char * function, parameters * params);
	execution_result* execute_with_params(wchar_t * function, parameters * params);

	bool create_delegates();

	virtual bool create_delegate(const CHARSTRING * delegate_name, void** func) = 0;

	reflect_function * get_functions(int * count);
	void destroy_execution_result(execution_result* er);
};

#endif