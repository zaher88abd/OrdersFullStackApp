import * as Sentry from "@sentry/node";

Sentry.init({
    dsn: "https://5ab4fc24c571e1b899f72d5754c905aa@o4510094273806336.ingest.us.sentry.io/4510094586740736",

  // Send structured logs to Sentry
  enableLogs: true,

  // Setting this option to true will send default PII data to Sentry.
  // For example, automatic IP address collection on events
  sendDefaultPii: true,

  // Environment configuration
  environment: process.env.NODE_ENV || "development",

  // Sample rate for performance monitoring
  tracesSampleRate: process.env.NODE_ENV === "production" ? 0.1 : 1.0,

  // Integrations
  integrations: [
    // Send console.log, console.warn, and console.error calls as logs to Sentry
    Sentry.consoleLoggingIntegration({ levels: ["log", "warn", "error"] }),
  ],
});

// Export Sentry for use in other modules
export { Sentry };