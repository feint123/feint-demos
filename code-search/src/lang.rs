use tree_sitter::Language;

pub trait SymbolQuery {
    fn get_queries(&self) -> Vec<String>;
    fn get_lang(&self) -> Language;
}
pub struct RustQuery;

pub struct JavaQuery;

pub struct PythonQuery;

pub struct JavascriptQuery;

pub struct CQuery;

pub struct CppQuery;

pub struct GoQuery;

pub struct CSharpQuery;

impl SymbolQuery for CSharpQuery {
    fn get_queries(&self) -> Vec<String> {
        return vec![
            String::from(
                r#"
            ((struct_declaration
             name:(identifier) @struct)
             (#match? @struct ":?"))
            "#,
            ),
            String::from(
                r#"
            ((class_declaration
             name:(identifier) @class)
             (#match? @class ":?"))
            "#,
            ),
            String::from(
                r#"
            ((method_declaration
             name:(identifier) @method)
             (#match? @method ":?"))
            "#,
            ),
        ];
    }

    fn get_lang(&self) -> Language {
        tree_sitter_c_sharp::language()
    }
}

impl SymbolQuery for GoQuery {
    fn get_queries(&self) -> Vec<String> {
        return vec![
            String::from(
                r#"
            ((function_declaration
             name:(identifier) @function)
             (#match? @function ":?"))
            "#,
            ),
            String::from(
                r#"
            ((type_spec
             name:(type_identifier) @type)
             (#match? @type ":?"))
            "#,
            ),
        ];
    }

    fn get_lang(&self) -> Language {
        tree_sitter_go::language()
    }
}

impl SymbolQuery for JavascriptQuery {
    fn get_queries(&self) -> Vec<String> {
        return vec![String::from(
            r#"
            ((function_declaration
             name:(identifier) @function)
             (#match? @function ":?"))
            "#,
        )];
    }

    fn get_lang(&self) -> Language {
        tree_sitter_javascript::language()
    }
}

impl SymbolQuery for CppQuery {
    fn get_queries(&self) -> Vec<String> {
        return vec![
            String::from(
                r#"
            ((function_definition
                declarator:(
                    function_declarator
                        declarator:(identifier) @function
                )
            )
            (#match? @function ":?"))
            "#,
            ),
            String::from(
                r#"
                ((struct_specifier
                    name:(type_identifier) @struct)
                    (#match? @struct ":?"))
                "#,
            ),
            String::from(
                r#"
                ((class_specifier
                    name:(type_identifier) @class)
                    (#match? @class ":?"))
                "#,
            ),
        ];
    }

    fn get_lang(&self) -> Language {
        tree_sitter_cpp::language()
    }
}

impl SymbolQuery for CQuery {
    fn get_queries(&self) -> Vec<String> {
        return vec![
            String::from(
                r#"
            ((function_definition
                declarator:(
                    function_declarator
                        declarator:(identifier) @function
                )
            )
            (#match? @function ":?"))
            "#,
            ),
            String::from(
                r#"
                ((struct_specifier
                    name:(type_identifier) @struct)
                    (#match? @struct ":?"))
                "#,
            ),
        ];
    }

    fn get_lang(&self) -> Language {
        tree_sitter_c::language()
    }
}

impl SymbolQuery for PythonQuery {
    fn get_queries(&self) -> Vec<String> {
        return vec![
            String::from(
                r#"
            ((function_definition
             name:(identifier) @function)
             (#match? @function ":?"))
            "#,
            ),
            String::from(
                r#"
                ((class_definition
                    name:(identifier) @class)
                    (#match? @class ":?"))
                "#,
            ),
        ];
    }

    fn get_lang(&self) -> Language {
        tree_sitter_python::language()
    }
}

impl SymbolQuery for RustQuery {
    fn get_queries(&self) -> Vec<String> {
        return vec![
            String::from(
                r#"
            ((function_item
             name:(identifier) @function)
             (#match? @function ":?"))
            "#,
            ),
            String::from(
                r#"
                ((struct_item
                    name:(type_identifier) @struct)
                    (#match? @struct ":?"))
                "#,
            ),
        ];
    }

    fn get_lang(&self) -> Language {
        tree_sitter_rust::language()
    }
}

impl SymbolQuery for JavaQuery {
    fn get_queries(&self) -> Vec<String> {
        return vec![
            String::from(
                r#"
            ((method_declaration
             name:(identifier) @method)
             (#match? @method ":?"))
            "#,
            ),
            String::from(
                r#"
                ((class_declaration
                    name:(identifier) @class)
                    (#match? @class ":?"))
                "#,
            ),
            String::from(
                r#"
                ((interface_declaration
                    name:(identifier) @interface)
                    (#match? @interface ":?"))
                "#,
            ),
        ];
    }

    fn get_lang(&self) -> Language {
        tree_sitter_java::language()
    }
}
