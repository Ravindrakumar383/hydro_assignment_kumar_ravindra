# Stage 1: Build Stage
FROM python:3.10-slim AS builder
WORKDIR /app
RUN pip install poetry
COPY pyproject.toml poetry.lock ./
RUN poetry config virtualenvs.in-project true && \
    poetry install --no-root --without test
# Stage 2: Runtime Stage
FROM python:3.10-slim
WORKDIR /app
COPY --from=builder /app/.venv /app/.venv
COPY src/ .
ENV PATH="/app/.venv/bin:$PATH"
# Run the gRPC server  (so it can communicate with dagster compoenent and core comepenents are not effected by this deployment)
CMD ["dagster", "api", "grpc", "-h", "0.0.0.0", "-p", "3030", "-m", "repository"]
