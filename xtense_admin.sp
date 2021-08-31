#include <sourcemod>
#include <sdktools>
#include <cstrike>
 
#define COLOR_PREFIX      "\x01 \x0B[\x01Xtense\x0B]\x01"
#define COLOR_NORMAL      "\x01"
#define COLOR_HIGHLIGHT   "\x0B"

#define CHAT_SYMBOL       '#'

// Command Includes
//#include "xtense_admin/hp.sp";

public Plugin myinfo = {
    name = "Xtense :: Admin",
    author = "dnhen",
    description = "Light weight admin system",
    version = "0.2",
    url = "http://www.sourcemod.net/"
};

public void OnPluginStart()
{
    // Command registers (remember to add the include for the file)

    RegConsoleCmd("say", Command_SayChat); // For admin broadcast
}

public Action Command_SayChat(int client, int args)
{
    // Get the whole text e.g. "# admin text"
    char text[192];
    GetCmdArgString(text, sizeof(text));

    if(FindCharInString(text, CHAT_SYMBOL) == 1 && CheckCommandAccess(client, "generic_admin", ADMFLAG_GENERIC, false) && strlen(text) > 4 && FindCharInString(text[2], CHAT_SYMBOL) != 0){ // If typed in chat CHAT_SYMBOL and is admin, and the second char in the message is NOT CHAT_SYMBOL (and message length is > 4)
        // Get admin's username
        char username[64];
        GetClientName(client, username, sizeof(username));

        if(FindCharInString(text, ' ') == 2){ // If there is a space after the admin char e.g. "# text"
            strcopy(text, sizeof(text), text[3]); // Copy from position 3 onwards e.g. "# test" -> "test"
        } else {
            strcopy(text, sizeof(text), text[2]); // Copy from position 2 onwards e.g. "#test" -> "test"
        }

        text[strlen(text) - 1] = 0; // Remove trailing '"' character (comes from text arg)

        // Print admin message to all users
        PrintToChatAll("%s %s%s%s: %s", COLOR_PREFIX, COLOR_HIGHLIGHT, username, COLOR_NORMAL, text);
        PrintHintTextToAll("%s %s%s%s: %s", COLOR_PREFIX, COLOR_HIGHLIGHT, username, COLOR_NORMAL, text);
    }


    return Plugin_Handled;
}